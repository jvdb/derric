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

module lang::derric::GenerateJava

import String;

import lang::derric::FileFormat;
import lang::derric::Validator;
import lang::derric::GenerateGlobalJava;
import lang::derric::GenerateSymbolJava;
import lang::derric::GenerateStructureJava;
import lang::derric::GenerateDerric;

public str generate(list[Symbol] sequence, str extension, Validator validator, str packageName) {
	initLabel();
	return
"package <packageName>;

import static org.derric_lang.validator.ByteOrder.*;

public class <validator.name> extends org.derric_lang.validator.Validator {

<for (g <- validator.globals) {><generateGlobal(g)>\n<}>

	public <validator.name>() { super(\"<validator.format>\"); }

	@Override
	public String getExtension() { return \"<extension>\"; }

	@Override
	public org.derric_lang.validator.ParseResult tryParseBody() throws java.io.IOException {
<for (symbol <- sequence) {>_currentSymbol = \"<writeSymbol(symbol)>\";<generateSymbol(symbol)><}>
		return yes();
	}

	@Override
	public org.derric_lang.validator.ParseResult findNextFooter() throws java.io.IOException {
		return yes();
	}

<for (struct <- validator.structs) {><generateStructure(struct)>\n<}>
}";
}
