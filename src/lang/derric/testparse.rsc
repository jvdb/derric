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

module lang::derric::testparse

import ParseTree;
import IO;
import String;
import List;
import Message;
import ToString;

import lang::derric::Syntax;
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
import lang::derric::ExecuteValidator;

str javaPackageName = "org.derric_lang.validator.generated";
str javaPathPrefix = "/" + replaceAll(javaPackageName, ".", "/") + "/";
str javaClassSuffix = "Validator";
str javaFileSuffix = ".java";

str derricFileSuffix = ".derric";

str formatPathPrefix = "../formats/";

public void generateAll() {
	generated = for (f <- enumerateDerricDescriptions()) {
		FileFormat format = load(|rascal:///<f>|);
		writeDerric(format);
		Validator validator = build(format);
		writeJava(format, validator);
		append format;
	}
	rel[str, str] mapping = { };
	for (f <- generated) {
		for (s <- f.extensions) {
			mapping += <s, toUpperCase(f.name) + javaClassSuffix>;
		}
	}
	println("Generating Factory");
	writeFile(|rascal:///<javaPathPrefix><javaClassSuffix>Factory<javaFileSuffix>|, generate(mapping));
}

private list[str] enumerateDerricDescriptions() {
	return for (f <- |rascal:///<formatPathPrefix>|.ls, isFile(f)) {
		append f.path;
	}
}

public void generate(loc path) {
	try {
		FileFormat format = load(path);
        writeDerric(format);
        Validator validator = build(format);
        writeJava(format, validator);
	} catch str s: {
		println("Error: <s>");
	}
}

public void execute(loc derricPath, loc inputPath) {
    try {
        FileFormat format = load(derricPath);
        Validator validator = build(format);
        println("Validator:                <validator>");
        println("Result:                   <executeValidator(validator.format, format.sequence, validator.structs, inputPath)>");
    } catch str s: {
        println("Error: <s>");
    }
}

public FileFormat load(loc path) {
	FileFormat format = build(parse(#start[Format], path).top);
	println("Imploded AST:             <format>");
	set[Message] messages = check(format);
	bool error = false;
	for (m <- messages) {
		switch (m) {
			case error(str msg, loc at): {
				print("ERROR");
				error = true;
			}
			case warning(str msg, loc at): print("WARNING");
			case info(str msg, loc at): print("INFO");
		}
		println(": " + m.msg + " (at: " + toString(m.at) + ")");
	}
	if (error) {
		throw "Errors occurred during compilation.";
	}
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

private void writeDerric(FileFormat format) {
    writeFile(|rascal://<javaPathPrefix><format.name><derricFileSuffix>|, lang::derric::GenerateDerric::generate(format));
}

private void writeJava(FileFormat format, Validator validator) {
    println("Validator:                <validator>");
    writeFile(|rascal://<javaPathPrefix><toUpperCase(format.name)><javaClassSuffix><javaFileSuffix>|, lang::derric::GenerateJava::generate(format.sequence, format.extensions[0], validator, javaPackageName));
}
