@license{
   Copyright 2011-2012 Netherlands Forensic Institute and
                       Centrum Wiskunde & Informatica

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
}

module Plugin

import lang::derric::Syntax;
import util::IDE;
import util::Prompt;
import ParseTree;
import Message;
import lang::derric::FileFormat;
import lang::derric::BuildFileFormat;
import lang::derric::DesugarFileFormat;
import lang::derric::CheckFileFormat;
import lang::derric::PropagateDefaultsFileFormat;
import lang::derric::PropagateConstantsFileFormat;
import lang::derric::AnnotateFileFormat;
import lang::derric::GenerateDerric;
import lang::derric::Validator;
import lang::derric::BuildValidator;
import lang::derric::GenerateJava;
import lang::derric::GenerateFactoryJava;
import lang::derric::OutlineFormat;
import String;
import IO;

private str DERRIC = "Derric";
private str DERRIC_EXT = "derric";

str javaClassSuffix = "Validator";
str javaFileSuffix = ".java";
str javaPackageName = "org.derric_lang.validator.generated";
str javaPathPrefix = "derric/src/" + replaceAll(javaPackageName, ".", "/") + "/";

public set[loc] getDerrics() {
  prefix = "derric/formats";
  result = {};
  for (path <- listEntries(|project://<prefix>|), endsWith(path, ".derric")) {
     println(path);
     result += {|project://<prefix>/<path>|};
  }
  return result;
}

public void main() {
  registerLanguage(DERRIC, DERRIC_EXT, start[Format](str input, loc org) {
	      return parse(#start[Format], input, org);
  });
  
  contribs = {
    builder(set[Message] (start[Format] pt) {
      FileFormat format = build(pt.top);
      format = annotate(propagateConstants(desugar(propagateDefaults(format))));
      Validator validator = build(format);
      writeFile(|project://<javaPathPrefix><toUpperCase(format.name)><javaClassSuffix><javaFileSuffix>|, 
             generate(format.sequence, format.extensions[0], validator, javaPackageName));
      return {};
    }),
    
    popup(menu("Derric", [
    
    action("Generate Factory", void (Tree tree, loc selection) {
      generated = [ load(f) | f <- getDerrics() ];
      rel[str, str] mapping = { <s, toUpperCase(f.name) + javaClassSuffix> | f <- generated, s <- f.extensions };
      println("Generating Factory");
       writeFile(|project://<javaPathPrefix><javaClassSuffix>Factory<javaFileSuffix>|, generate(mapping));
    }),
    
    action("Compile all", void (Tree tree, loc selection) {
      for (f <- getDerrics()) {
        FileFormat format = load(f);
        Validator validator = build(format);
        writeFile(|project://<javaPathPrefix><toUpperCase(format.name)><javaClassSuffix><javaFileSuffix>|, 
             generate(format.sequence, format.extensions[0], validator, javaPackageName));
      }
    }),
    
    edit("Rename structure...", str (Tree pt, loc selection) {
       newName = prompt("Enter new name: ");
       return unparse(rename(pt, selection, newName));
    })
    
    ])),
  
  
    annotator(start[Format] (start[Format] pt) {
      ast = build(pt.top);
      msgs = check(ast);
      pt = xrefFormat(pt);
      return pt[@messages=msgs];
    }),
    
    outliner(node (start[Format] pt) {
      return outline(build(pt.top));
    })
  };
  
  registerContributions(DERRIC, contribs);	  
}


public start[Format] rename(start[Format] pt, loc oldLoc, str newName) {
  try {
    Id new = parse(#Id, newName);
    if (treeFound(Id old) := treeAt(#Id, oldLoc, pt)) {
      pt = visit (pt) {
        case StructureHead h: {
          if (h.name == old) {
            h.name = new;
          }
          if (h has super, h.super == old) {
            h.super = new;
          }
          insert h; 
        }
      }
      pt.top.seq = visit (pt.top.seq) {
        case old => new
      }
    }
    else {
      alert("Select an identifier first");
    }
  }
  catch _:
    alert("Not a valid new name");
  return pt; 
}

public start[Format] xrefFormat(start[Format] pt) {
  table = ();
  
  pt.top.structs = visit (pt.top.structs) {
    case lang::derric::Syntax::Structure x: {
        table[x.head.name] = (x.head)@\loc;
        ftable = ();
        visit (x.fields) {
          case lang::derric::Syntax::Field f: 
            ftable["<f.name>"] = f@\loc;
        }
        x.fields = visit (x.fields) {
          case ExpressionId eid => eid[@link=ftable["<eid>"]]
                   when ftable["<eid>"]?
        }
        insert x;
    }
  }
  
  
  pt.top.seq = visit (pt.top.seq) {
    case Id id => id[@link=table[id]]
       when table[id]? 
  }
  
  pt.top.structs = visit (pt.top.structs) {
    case StructureHead h => h[super=h.super[@link=table[h.super]]]
      when h has super, table[h.super]?
  }
  
  return pt;
}


public FileFormat load(loc path) {
    FileFormat format = build(parse(#start[Format], path).top);
    println("Imploded AST:             <format>");
    format = propagateDefaults(format);
    println("Defaults Propagated AST:  <format>");
    format = desugar(format);
    println("Desugared AST:            <format>");
    format = propagateConstants(format);
    println("Constants Propagated AST: <format>");
    format = annotate(format);
    println("Annotated AST:            <format>");
    return format;
}