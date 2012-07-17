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
    
    popup(menu("Derric", [action("Generate Factory", void (Tree tree, loc selection) {
      list[str] formats = ["gif", "jpeg", "png"];
      str formatPathPrefix = "derric/formats/";
      generated = [ load(|project://<formatPathPrefix><f>.derric|) | f <- formats ];
      rel[str, str] mapping = { <s, toUpperCase(f.name) + javaClassSuffix> | f <- generated, s <- f.extensions };
      println("Generating Factory");
       writeFile(|project://<javaPathPrefix><javaClassSuffix>Factory<javaFileSuffix>|, generate(mapping));
    })])),
  
  
    annotator(start[Format] (start[Format] pt) {
      ast = build(pt.top);
      msgs = check(ast);
      return pt[@messages=msgs];
    }),
    
    outliner(node (start[Format] pt) {
      return outline(build(pt.top));
    })
  };
  
  registerContributions(DERRIC, contribs);
	  
}

public FileFormat load(loc path) {
    FileFormat format = build(parse(#start[Format], path).top);
    println("Imploded AST:             <format>");
    //list[CheckResult] checkResults = check(format);
    //if (!isEmpty(checkResults)) {
    //    for (error(str message) <- checkResults) {
    //        println("ERROR: " + message);
    //    }
    //    return;
    //}
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