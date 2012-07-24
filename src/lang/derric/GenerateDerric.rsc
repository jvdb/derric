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

module lang::derric::GenerateDerric

import List;
import Set;
import String;

import lang::derric::FileFormat;
import lang::derric::PropagateDefaultsFileFormat;

map[str,str] mapping = ("*":"_");

public str generate(FileFormat format) {
	str res = "";
	res += "format <format.name>\n";
	
	res += "extension";
	for (str s <- format.extensions) {
		res += " <s>";
	}
	res += "\n\n";
	
	list[Qualifier] defaults = getDefaultQualifiers();
	set[Qualifier] defined = toSet(format.defaults) - toSet(defaults);
	bool qualifierWritten = false;
	for (Qualifier q <- defined) {
		qualifierWritten = true;
		switch(q) {
			case unit(str name): res += "unit <name>\n";
			case sign(bool present): res += "sign <present>\n";
			case endian(str name): res += "endian <name>\n";
			case strings(str encoding): res += "strings <encoding>\n";
			case \type(str \type): res += "type <\type>\n";
			case size(Expression count): res += "size <writeExpression(count, true)>\n";
		}
	}
	if (qualifierWritten) {
		res += "\n";
	}
	
	res += "sequence\n";
	for (Symbol s <- format.sequence) {
		res += "  <writeSymbol(s)>\n";
	}

	res += "\n";
	res += "structures";
	for (Term t <- format.terms) {
		switch(t) {
			case term(str name, list[Field] fields): {
				res += "\n\n<name> {\n";
				for (Field f <- fields) {
					res += "  <writeField(f)>\n";
				}
				res += "}";
			}
			case term(str name, str source, list[Field] fields): {
				res += "\n\n<name> = <source> {\n";
				for (Field f <- fields) {
					res += "  <writeField(f)>\n";
				}
				res += "}";
			}
		}
	}

	return res;
}

private str writeField(Field f) {
	str res = escape(f.name, mapping);
	list[Qualifier] overridden = getLocalQualifiers(f);
	if (isEmpty(overridden) && field(_, _, _, Expression specification) := f && noValue() := f.specification) {
		res += ";";
	} else {
		res += ":";
		for (Modifier m <- f.modifiers) {
			switch(m) {
				case required():;
				case expected(): res += " expected";
				case terminator(true): res += " terminatedBy";
				case terminator(false): res += " terminatedBefore";
			}
		}
		str exp = "";
		if (field(_, _, _, Expression specification) := f) {
			exp = writeExpression(specification, true);
		} else {
			exp = writeContentSpecifier(f.specifier);
		}
		if (size(exp) > 0) {
			res += " " + exp;
		}
		for (Qualifier q <- overridden) {
			res += " ";
			switch(q) {
				case unit(str name): res += "unit <name>";
				case sign(bool present): res += "sign <present>";
				case endian(str name): res += "endian <name>";
				case strings(str encoding): res += "strings <encoding>";
				case \type(str \type): res += "type <\type>";
				case size(Expression count): res += "size <writeExpression(count, true)>";
			}
		}
		res += ";";
	}
	return res;
}

private list[Qualifier] getLocalQualifiers(Field f) {
	return for (Qualifier q <- f.qualifiers) {
		if ((q@local)?) append q;
	}
}

private str writeContentSpecifier(ContentSpecifier specifier) {
	str res = "<specifier.name>(";
	bool first = true;
	for (tuple[str k, list[Specification] v] a <- specifier.arguments) {
		if (first) {
			first = false;
		} else {
			res += ",";
		}
		res += "<a.k>=<writeSpecification(a.v)>";
	}
	res += ")";
	return res;
}

private str writeSpecification(list[Specification] ls) {
	bool first = true;
	str ret = "";
	for (Specification spec <- ls) {
		if (first) {
			first = false;
		} else {
			ret += "+";
		}
		switch (spec) {
			case const(str s): ret += "\"<s>\"";
			case const(int i): ret += "<i>";
			case field(str name): ret += escape("<name>", mapping);
			case field(str struct, str name): ret += escape("<struct>.<name>", mapping);
		}
	}
	return ret;
}

public str writeSymbol(Symbol s) {
	switch(s) {
		case term(str name): return name;
		case optional(Symbol symbol): return "<writeSymbol(symbol)>?";
		case iter(Symbol symbol): return "<writeSymbol(symbol)>*";
		case not(Symbol symbol): return "!<writeSymbol(symbol)>";
		case anyOf(set[Symbol] symbols): return "(<("" | it + " " + symbol | sym <- symbols, symbol := writeSymbol(sym))> )";
		case seq(list[Symbol] symbolSequence): return "[<("" | it + " " + symbol | sym <- symbolSequence, symbol := writeSymbol(sym))> ]";
	}
}

private str writeExpression(Expression exp, bool top) {
	switch(exp) {
		case ref(str name): return escape(name, mapping);
		case ref(str struct, str name): return "<struct>.<escape(name, mapping)>";
		case not(Expression e): return "!<top ? "" : "("><writeExpression(e, false)><top ? "" : ")">";
		case pow(Expression b, Expression e): return "<top ? "" : "("><writeExpression(b, false)>^<writeExpression(e, false)><top ? "" : ")">";
		case minus(Expression l, Expression r): return "<top ? "" : "("><writeExpression(l, false)>-<writeExpression(r, false)><top ? "" : ")">";
		case times(Expression l, Expression r): return "<top ? "" : "("><writeExpression(l, false)>*<writeExpression(r, false)><top ? "" : ")">";
		case add(Expression l, Expression r): return "<top ? "" : "("><writeExpression(l, false)>+<writeExpression(r, false)><top ? "" : ")">";
		case divide(Expression l, Expression r): return "<top ? "" : "("><writeExpression(l, false)>/<writeExpression(r, false)><top ? "" : ")">";
		case \value(int v): return "<v>";
		case \value(str v): return "\"<v>\"";
		case lengthOf(str name): return "lengthOf(<escape(name, mapping)>)";
		case lengthOf(str struct, str name): return "lengthOf(<struct>.<escape(name, mapping)>)";
		case offset(str name): return "offset(<escape(name, mapping)>)";
		case offset(str struct, str name): return "offset(<struct>.<escape(name, mapping)>)";
		case or(Expression l, Expression r): return "<writeExpression(l, false)>|<writeExpression(r, false)>";
		case range(Expression f, Expression t): return "<top ? "" : "("><writeExpression(f, false)>..<writeExpression(t, false)><top ? "" : ")">";
		case negate(Expression e): return "-<top ? "" : "("><writeExpression(r, false)><top ? "" : ")">";
	}
	return "";
}
