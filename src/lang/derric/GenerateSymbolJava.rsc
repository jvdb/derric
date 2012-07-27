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

module lang::derric::GenerateSymbolJava

import IO;
import List;
import Set;

import lang::derric::FileFormat;

int label;

public void initLabel() {
	label = 0;
}

private int getNextLabel() {
	label += 1;
	return label;
}

public str generateSymbol(iter(anyOf(set[Symbol] symbols))) {
	return "top<getNextLabel()>: for (;;) {\n<generateAnyOfSymbols(symbols, true)>break top<label>;\n}\n";
}

public str generateSymbol(anyOf(set[Symbol] symbols)) {
	return "top<getNextLabel()>: for (;;) {\n<generateAnyOfSymbols(symbols, false)><containsEmptyList(symbols) ? "break top<label>" : "return no()">;\n}\n";
}

public default str generateSymbol(Symbol symbol) {
	return "// skipped: <symbol>\n";
}

private str generateAnyOfSymbols(set[Symbol] symbols, bool iterate) {
	str res = "";
	str fin = "";

	void generateAnyOfSymbol(Symbol s, bool final) {
		//println("generating: <s>");
		str breakTarget = final ? "break top<label>" : "break";
		//println(breakTarget);
		if (res == "") {
			switch (s) {
				case term(str name): res += "if (parse<name>()) { <iterate ? "continue" : breakTarget>; }\n";
				case optional(term(str name)): res += "parse<name>();\n<iterate ? "continue" : breakTarget>;\n";
				case iter(term(str name)): res += "for (;;) {\nif (parse<name>()) { continue; }\n<breakTarget>;\n}\n";
			}
		} else {
			switch (s) {
				case term(str name): res = "if (parse<name>()) {\n<res>}\n";
				case optional(term(str name)): res = "parse<name>();\n<res>";
				case iter(term(str name)): res = "for (;;) {\nif (parse<name>()) { continue; }\n<breakTarget>;\n}\n<res>";
			}
		}
	}

	for (seq(list[Symbol] sequence) <- symbols) {
		//println("generating: <sequence>");
		sequence = reverse(sequence);
		bool innerMost = true;
		while (!isEmpty(sequence)) {
			//println("Generating sequence: <sequence>, <size(tail(sequence))>"); 
			generateAnyOfSymbol(head(sequence), innerMost);
			innerMost = false;
			sequence = tail(sequence);
		}
		if (res != "") {
			fin += "_input.mark();\n" + res + "_input.reset();";
		}
		res = "";
	}
	return fin;
}

private bool containsEmptyList(set[Symbol] symbols) {
	for (seq(list[Symbol] sequence) <- symbols) {
		if (size(sequence) == 0) {
			return true;
		}
	}
	return false;
}
