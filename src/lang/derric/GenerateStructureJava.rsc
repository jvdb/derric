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

module lang::derric::GenerateStructureJava

import lang::derric::Validator;
import lang::derric::GenerateGlobalJava;

public str generateStructure(Structure struct) {
	str ret = "private boolean parse<struct.name>() throws java.io.IOException {markStart();";
	int i = 0;
	for (s <- struct.statements) {
		switch (s) {
			case ldeclV(integer(bool sign, _, int bits), str n): ret += "<generateIntegerDeclaration(sign, bits, n)>";
			case ldeclV(float(_, int bits), str n): ret += "<generateFloatDeclaration(bits, n)>";
			case ldeclB(str n): ret += "org.derric_lang.validator.SubStream <n> = new org.derric_lang.validator.SubStream();";
			case calc(str n, VExpression e): ret += "<n> = <generateValueExpression(e)>;";
			case readValue(Type t, str n): ret += "<n> = <generateReadValueMethodCall(t)>;";
			case readBuffer(str s, str n): ret += "<n>.addFragment(_input, <s>);";
			case readUntil(Type t, list[VExpression] l, bool includeTerminator): ret += "<generateValueSet(l, "vs<i>")>if (!_input.<t.sign ? "signed()" : "unsigned()">.<(little() := t.endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.includeMarker(<includeTerminator ? "true" : "false">).readUntil(<t.bits>, vs<i>).validated) return noMatch();";
			case skipValue(Type t): ret += "if (!_input.skipBits(<t.bits>)) return noMatch();";
			case skipBuffer(str s): ret += "if (_input.skip(<s>) != <s>) return noMatch();";
			case validate(str v, list[VExpression] l): ret += "<generateValueSet(l, "vs<i>")>if (!vs<i>.equals(<v>)) return noMatch();";
			case validateContent(str v, str l, str n, map[str, str] configuration, map[str, list[VExpression]] arguments, bool allowEOF): ret += "<makeStringMap("content1_<i>", configuration)><makeExpressionMap("content2_<i>", arguments)>org.derric_lang.validator.Content content3_<i> = _input.validateContent(<l>, \"<n>\", content1_<i>, content2_<i>, allowEOF || <allowEOF>); if (!content3_<i>.validated) return noMatch();<v>.fragments.add(content3_<i>.data);<l> = <v>.getLast().length;";
		}
		i += 1;
	}
	ret += "addSubSequence(\"<struct.name>\");return true; }";
	return ret;
}

private str generateValueSet(list[VExpression] le, str vs) {
	str ret = "org.derric_lang.validator.ValueSet <vs> = new org.derric_lang.validator.ValueSet();";
	for (VExpression exp <- le) {
		switch (exp) {
			case not(range(VExpression l, VExpression u)): ret += "<vs>.addNot(<generateValueExpression(l)>, <generateValueExpression(u)>);";
			case not(VExpression e): ret += "<vs>.addNot(<generateValueExpression(e)>);";
			case range(VExpression l, VExpression u): ret += "<vs>.addEquals(<generateValueExpression(l)>, <generateValueExpression(u)>);";
			default: ret += "<vs>.addEquals(<generateValueExpression(exp)>);";
		}
	}
	return ret;
}

private str generateValueExpression(VExpression exp) {
	top-down visit (exp) {
		case var(str n): return n;
		case con(int i): {
			if (i <= 2147483647) {
				return "<i>";
			} else {
				return "<i>l";
			}
		}
		case con(real r): return "<r>f";
		case sub(VExpression l, VExpression r): return "(<generateValueExpression(l)>-<generateValueExpression(r)>)";
		case add(VExpression l, VExpression r): return "(<generateValueExpression(l)>+<generateValueExpression(r)>)";
		case fac(VExpression l, VExpression r): return "(<generateValueExpression(l)>*<generateValueExpression(r)>)";
		case div(VExpression l, VExpression r): return "(<generateValueExpression(l)>/<generateValueExpression(r)>)";
		case pow(VExpression b, VExpression e): return "(int)java.lang.Math.pow(<generateValueExpression(b)>, <generateValueExpression(e)>)";
		case neg(VExpression e): return "-<generateValueExpression(e)>";
	}
}

private str generateReadValueMethodCall(Type \type) {
	switch (\type) {
		case integer(bool sign, Endianness endian, int bits): return "_input.<sign ? "signed()" : "unsigned()">.<(little() := endian) ? "byteOrder(LITTLE_ENDIAN)" : "byteOrder(BIG_ENDIAN)">.readInteger(<bits>)";
	}
}

private str makeList(str n, list[VExpression] l) {
	str ret = "java.util.ArrayList\<Long\> <n> = new java.util.ArrayList\<Long\>();";
	for (e <- l) ret += "<n>.add((long)<generateValueExpression(e)>);";
	return ret;
}

private str makeStringMap(str n, map[str, str] m) {
	str ret = "java.util.HashMap\<String, String\> <n> = new java.util.HashMap\<String, String\>();";
	for (k <- m) ret += "<n>.put(\"<k>\", \"<m[k]>\");";
	return ret;
}

private str makeExpressionMap(str n, map[str, list[VExpression]] m) {
	str ret = "java.util.HashMap\<String, java.util.List\<Object\>\> <n> = new java.util.HashMap\<String, java.util.List\<Object\>\>();";

	int i = 0;
	for (k <- m) {
		ret += "java.util.ArrayList\<Object\> <n>_<i> = new java.util.ArrayList\<Object\>();";
		for (VExpression v <- m[k]) {
			switch (v) {
				case var(str v): ret += "<n>_<i>.add(<v>);";
				case con(int t): ret += "<n>_<i>.add(<t>l);";
				case con(real r): ret += "<n>_<i>.add(<r>f);";
			}
		}
		ret += "<n>.put(\"<k>\", <n>_<i>);";
		i += 1;
	}
	return ret;
}
