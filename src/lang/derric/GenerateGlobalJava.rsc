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

module lang::derric::GenerateGlobalJava

import String;

import lang::derric::Validator;

public str generateGlobal(Global global) {
	switch (global) {
		case gdeclV(integer(bool sign, _, int bits), str n): return "private <generateIntegerDeclaration(sign, bits, n)>";
		case gdeclV(float(_, int bits), str n): return "private <generateFloatDeclaration(bits, n)>";
		case gdeclB(str n): return "private org.derric_lang.validator.SubStream <n> = new org.derric_lang.validator.SubStream();";
	}
}

public str generateIntegerDeclaration(bool sign, int bits, str name) {
	if (sign) bits += 1;
	if (bits <= 64) return "long <name>;";
	else return "org.derric_lang.validator.SubStream <name> = new org.derric_lang.validator.SubStream();";
}

public str generateFloatDeclaration(int bits, str name) {
	if (bits <= 32) return "float <name>;";
	else if (bits <= 64) return "double <name>;";
}
