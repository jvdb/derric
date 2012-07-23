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

module lang::derric::BuildValidator

import IO;
import List;
import Set;
import String;

import lang::derric::FileFormat;
import lang::derric::AnnotateFileFormat;
import lang::derric::Validator;
import lang::derric::PropagateDefaultsFileFormat;

data EType = \value() | size();

map[str,str] mapping = ("*":"_");

@doc{Produce an AST (Validator) based on a provided AST (FileFormat).}
public Validator build(FileFormat format) {
	list[Global] globals = [];
	list[Structure] structures = [];
	list[Statement] statements = [];
	str struct = "";
	rel[str,str,EType,Statement] frefs = {};

	void buildStatements(f:Field::field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, Expression specification)) {
		name = escape(name, mapping);
		if (isVariableSize(f)) {
			// handles value=noValue(), size=Expression, @ref=none/local()/global(), @size=none/local()/global()
			// when size=Expression, value *must* be noValue() and @refdep and @sizedep are forbidden
			str lenName = "<struct>_<name>_len";
			Type lenType = integer(true, little(), 31);
			if ((f@size)? && global() := f@size) globals += gdeclV(lenType, lenName);
			else statements += ldeclV(lenType, lenName);
			//Expression sizeExp = (qualifiers[0].name == "byte") ? times(qualifiers[5].count, \value(8)) : qualifiers[5].count;
			//statements += calc(lenName, generateExpression(struct, sizeExp));
			statements += calc(lenName, generateExpression(struct, qualifiers[5].count));
			for (Statement s <- frefs[struct,name,size()]) statements += s;
			if ((f@ref)?) {
				str bufName = "<struct>_<name>";
				if (global() := f@ref) globals += gdeclB(bufName);
				else statements += ldeclB(bufName);
				statements += readBuffer(lenName, bufName);
			} else {
				statements += skipBuffer(lenName);
			}
		} else if (!isTerminatorSpecification(modifiers)) {
			// handles value=Expression, size=\value(int), @ref=none/local()/global(), @sizedep=dependency(str) and @refdep=dependency(str)
			// @size won't occur because of constant size and constant folding and propagation
			Type t = makeType(qualifiers);
			if (!(f@ref)? && !(f@refdep)? && !(f@sizedep)? && !hasValueSpecification(f)) {
				statements += skipValue(t);
			} else {
				str valName = "<struct>_<name>";
				if ((f@ref)? && global() := f@ref) globals += gdeclV(t, valName);
				else statements += ldeclV(t, valName);
				statements += readValue(t, valName);
				if (hasValueSpecification(f)) {
					Statement validateStatement = generateValidateStatement(valName, struct, specification);
					if ((f@refdep)? && dependency(str depName) := f@refdep) frefs += <struct, depName, \value(), validateStatement>;
					else if ((f@sizedep)? && dependency(str depName) := f@sizedep) frefs += <struct, depName, size(), validateStatement>;
					else statements += validateStatement;
				}
				for (Statement s <- frefs[struct,name,\value()]) statements += s;
			}
		} else {
			// handles value=Expression, size=\value(int), modifier=terminatedBy/terminatedBefore
			// no references are allowed
			Type t = makeType(qualifiers);
			if (terminator(bool includeTerminator) := getTerminator(modifiers)) {
				statements += generateReadUntilStatement(t, struct, specification, includeTerminator);
			} else {
				throw "buildStatements: Unsupported field encountered: <f>";
			}
		}
	}
	
	void buildStatements(f:Field::field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, ContentSpecifier specifier)) {
		name = escape(name, mapping);
		// handles value=ContentSpecifier
		map[str, str] custom = ();
		map[str, list[VExpression]] references = ();
		for (<n, e> <- specifier.arguments) {
			if (const(str v) := getOneFrom(e)) custom += (n : v);
			else {
				specs = for (Specification spec <- e) {
					append generateSpecification(struct, spec);
				}
				references += (n : specs);
			}
		}
		// handles @ref=none/local()/global()
		str valName = "<struct>_<name>";
		if ((f@ref)? && global() := f@ref) globals += gdeclB(valName);
		else statements += ldeclB(valName);
		// handles @size=none/local()/global()
		str lenName = "<struct>_<name>_len";
		Type lenType = integer(true, little(), 31);
		if ((f@size)? && global() := f@size) globals += gdeclV(lenType, lenName);
		else statements += ldeclV(lenType, lenName);
		if (hasLocalSize(f)) {
			// handles size=\value(int) or Expression and @refdep=dependency(str)
			// @sizedep is not allowed since lengthOf() and offset() are not allowed in expressions in ContentSpecifier arguments
			//Expression sizeExp = (qualifiers[0].name == "byte") ? times(qualifiers[5].count, \value(8)) : qualifiers[5].count;
			statements += calc(lenName, generateExpression(struct, qualifiers[5].count));
			for (Statement s <- frefs[struct,name,size()]) statements += s;
			Statement validateStatement = validateContent(valName, lenName, specifier.name, custom, references);
			if ((f@refdep)? && dependency(str depName) := f@refdep) frefs += <struct, depName, \value(), validateStatement>;
			else statements += validateStatement;
		} else {
			// handles size=undefined
			// no forward references are allowed since the content analysis must run order to reach following fields
			statements += calc(lenName, con(0));
			statements += validateContent(valName, lenName, specifier.name, custom, references);
		}
	}

	for (t <- format.terms) {
		struct = t.name;
		statements = [];
		for (f <- t.fields) {
			buildStatements(f);
		}
		structures += structure(t.name, statements);
	}

	return validator(toUpperCase(format.name) + "Validator", format.name, globals, structures);
}

private VExpression generateSpecification(str struct, Specification spec) {
	switch (spec) {
		case const(int i): return con(i);
		case field(str name): return var("<struct>_<escape(name, mapping)>");
		case field(str struct, str name): return var("<struct>_<escape(name, mapping)>");
		default: throw "generateSpecification: unknown Specification <spec>";
	}
}

private bool isVariableSize(Field field) {
	return !(\value(int i) := field.qualifiers[5].count);
}

private bool hasValueSpecification(Field field) {
	return !(noValue() := field.specification);
}

private bool hasLocalSize(Field field) {
	return ((field.qualifiers[5]@local)? && (field.qualifiers[5]@local));
}

private bool isTerminatorSpecification(list[Modifier] modifiers) {
	for (m <- modifiers) {
		if (terminator(bool includeTerminator) := m) {
			return true;
		}
	}
	return false;
}

private Type makeType(list[Qualifier] qualifiers) {
	int bitLength = qualifiers[5].count.i * ((qualifiers[0].name == "byte") ? 8 : 1);
	Endianness endian = (qualifiers[2].name == "little") ? little() : big();
	bool sign = qualifiers[1].present;
	if (qualifiers[4].\type == "integer") return integer(sign, endian, bitLength);
	else if (qualifiers[4].\type == "float") return float(endian, bitLength);
	else if (qualifiers[4].\type == "string") return integer(sign, endian, bitLength);
}

private VExpression generateExpression(str struct, Expression exp) {
	top-down visit (exp) {
		case ref(str name): return var("<struct>_<name>");
		case ref(str struct, str name): return var("<struct>_<name>");
		case pow(Expression base, Expression exp): return pow(generateExpression(struct, base), generateExpression(struct, exp));
		case minus(Expression lhs, Expression rhs): return sub(generateExpression(struct, lhs), generateExpression(struct, rhs));
		case times(Expression lhs, Expression rhs): return fac(generateExpression(struct, lhs), generateExpression(struct, rhs));
		case add(Expression lhs, Expression rhs): return add(generateExpression(struct, lhs), generateExpression(struct, rhs));
		case divide(Expression lhs, Expression rhs): return div(generateExpression(struct, lhs), generateExpression(struct, rhs));
		case \value(int i): return con(i);
		case lengthOf(str name): return var("<struct>_<name>_len");
		case lengthOf(str struct, str name): return var("<struct>_<name>_len");
		case negate(Expression exp): return neg(generateExpression(struct, exp));
		case not(Expression exp): return not(generateExpression(struct, exp));
		case range(Expression lower, Expression upper): return range(generateExpression(struct, lower), generateExpression(struct, upper));
		default: throw "generateExpression: unknown Expression <exp>";
	}
}

private lang::derric::Validator::Statement generateValidateStatement(str valName, str struct, Expression exp) {
	switch (exp) {
		case or(Expression l, Expression r): return validate(valName, generateOrList(struct, exp));
		default: return validate(valName, [generateExpression(struct, exp)]);
	}
}

private lang::derric::Validator::Statement generateReadUntilStatement(Type \type, str struct, Expression exp, bool includeTerminator) {
	switch (exp) {
		case or(Expression l, Expression r): return readUntil(\type, generateOrList(struct, exp), includeTerminator);
		default: return readUntil(\type, [generateExpression(struct, exp)], includeTerminator);
	}
}

private list[VExpression] generateOrList(str struct, Expression e) {
	if (or(Expression l, Expression r) := e) {
		list[VExpression] orList = [];
		orList += generateOrList(struct, l);
		orList += generateOrList(struct, r);
		return orList;
	} else {
		list[VExpression] orList = [];
		orList += generateExpression(struct, e);
		return orList;
	}
}

private Modifier getTerminator(list[Modifier] modifiers) {
	for (m <- modifiers) {
		if (terminator(bool includeTerminator) := m) {
			return m;
		}
	}
}
