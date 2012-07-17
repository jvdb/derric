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
//import lang::derric::CheckFileFormat;
import lang::derric::PropagateDefaultsFileFormat;
import lang::derric::PropagateConstantsFileFormat;
import lang::derric::AnnotateFileFormat;
import lang::derric::GenerateDerric;
import lang::derric::Validator;
import lang::derric::BuildValidator;
import lang::derric::GenerateJava;
import String;
import IO;

private str DERRIC = "Derric";
private str DERRIC_EXT = "derric";

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
      writeFile(|project://<javaPathPrefix><toUpperCase(format.name)>Validator.java|, 
             generate(format.sequence, format.extensions[0], validator, javaPackageName));
      return {};
    })
  
  };
  
  registerContributions(DERRIC, contribs);
	  
}
