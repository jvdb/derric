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

module lang::derric::BuildFileFormat

import IO;
import String;
import List;
import Set;

import lang::derric::FileFormat;
import lang::derric::Syntax;

@doc{Produce an AST (FileFormat) based on a provided parse tree (Format).}
public FileFormat build(Format t) {
	if ((Format)`format <Id name> extension <Id+ extensions> <Defaults defaults> <Sequence sequence> <Structures structures>` := t) {
		return format("<name>", makeExtensions(extensions), makeDefaults(defaults), makeSequence(sequence), makeStructures(structures));
	}
}

private list[str] makeExtensions(Id+ extensions) {
	return for (e <- extensions) {
		append "<e>";
	}
}

private list[Qualifier] makeDefaults(Defaults defaults) {
	if ((Defaults)`<FormatSpecifier* formats>` := defaults) return makeQualifiers(formats);
}

private list[lang::derric::FileFormat::Symbol] makeSequence(Sequence sequence) {
	if ((Sequence)`sequence <SequenceSymbol* symbols>` := sequence) {
		return for (SequenceSymbol s <- symbols) {
			append makeSymbol(s);
		}
	}
}

private lang::derric::FileFormat::Symbol makeSymbol(lang::derric::Syntax::SequenceSymbol symbol) {
	switch (symbol) {
		case (SequenceSymbol)`<Id name>`: return term("<name>");
		case (SequenceSymbol)`<SequenceSymbol s>?`: return optional(makeSymbol(s));
		case (SequenceSymbol)`<SequenceSymbol s>*`: return iter(makeSymbol(s));
		case (SequenceSymbol)`!<SequenceSymbol s>`: return not(makeSymbol(s));
		case (SequenceSymbol)`( <SequenceSymbol+ symbols> )`: return anyOf({makeSymbol(s) | s <- symbols});
		case (SequenceSymbol)`[ <SequenceSymbol* symbols> ]`: return seq([makeSymbol(s) | s <- symbols]);
	}
}

private list[Term] makeStructures(Structures structureBlock) {
	if ((Structures)`structures <Structure* structures>` := structureBlock) {
		return for (structure <- structures, (Structure)`<StructureHead structureHead> { <Field* fields> }` := structure) {
			switch (structureHead) {
				case (StructureHead)`<Id name>`: append term("<name>", makeStructureFields(fields));
				case (StructureHead)`<Id name> = <Id source>`: append term("<name>", "<source>", makeStructureFields(fields));
				default: throw "makeStructures: unmatched StructureHead <structureHead>";
			}
		}
	}
}

private list[Field] makeStructureFields(Field* fields) {
	list[Field] results = [];
	for (lang::derric::Syntax::Field f <- fields) {
		switch (f) {
			case (Field)`<Id name>;`: results += field("<name>", [], [], noValue());
			case (Field)`<Id name>: <ValueModifier* modifiers> <lang::derric::Syntax::ContentSpecifier specifier> <FormatSpecifier* formats>;`: results += field("<name>", makeModifiers(modifiers), makeQualifiers(formats), makeContentSpecifier(specifier));
			case (Field)`<Id name>: <ValueModifier* modifiers> <{ Expression "," }+ expressions> <FormatSpecifier* formats>;`: results += field("<name>", makeModifiers(modifiers), makeQualifiers(formats), makeExpressionList(expressions));
			case (Field)`<Id name>: <FormatSpecifier+ formats>;`: results += field("<name>", [], makeQualifiers(formats), noValue());
			case (Field)`<Id name>: { <Field* descriptions> }`: results += field("<name>", makeStructureFields(descriptions));
			default : throw "makeStructureFields: unmatched Field <f>";
		}
	}
	return results;
}

private ContentSpecifier makeContentSpecifier(lang::derric::Syntax::ContentSpecifier cspec) {
	if ((ContentSpecifier)`<Id name> ( <{ ContentModifier "," }* modifiers> )` := cspec) {
		return specifier("<name>", makeContentModifiers(modifiers));
	}
}

private list[tuple[str, list[Specification]]] makeContentModifiers({ ContentModifier "," }* modifiers) {
	return for (ContentModifier modifier <- modifiers) {
		if ((ContentModifier)`<Id name> = <{ Argument "+" }+ args>` := modifier) {
			append <"<name>", makeSpecifications(args)>;
		} else {
			throw "makeContentModifiers: unmatched ContentModifier <modifier>";
		}
	}
}

private list[Specification] makeSpecifications({ Argument "+" }+ args) {
	return for (Argument arg <- args) {
		switch (arg) {
			case (Argument)`<String s>`: append const(makeString(s));
			case (Argument)`<Number i>`: append const(makeInt(i));
			case (Argument)`<Id id>`: append field("<id>");
			case (Argument)`<Id struct> . <Id name>`: append field("<struct>", "<name>");
			default: throw "makeSpecifications: unmatched Argument <arg>";
		}
	}
}

private list[Modifier] makeModifiers(ValueModifier* modifiers) {
	return for (ValueModifier modifier <- modifiers) {
		switch (modifier) {
			case (ValueModifier)`expected`: append expected();
			case (ValueModifier)`terminatedBefore`: append terminator(false);
			case (ValueModifier)`terminatedBy`: append terminator(true);
			default: throw "makeModifiers: unmatched ValueModifier <modifier>";
		}
	}
}

private list[Qualifier] makeQualifiers(FormatSpecifier* qualifiers) {
	return for (FormatSpecifier specifier <- qualifiers) {
		switch (specifier) {
			case (FormatSpecifier)`unit <FixedFormatSpecifierValue val>`: append unit("<val>");
			case (FormatSpecifier)`sign true`: append sign(true);
			case (FormatSpecifier)`sign false`: append sign(false);
			case (FormatSpecifier)`endian <FixedFormatSpecifierValue val>`: append endian("<val>");
			case (FormatSpecifier)`strings <FixedFormatSpecifierValue val>`: append strings("<val>");
			case (FormatSpecifier)`type <FixedFormatSpecifierValue val>`: append \type("<val>");
			case (FormatSpecifier)`size <lang::derric::Syntax::Expression exp>`: append size(makeExpression(exp));
			default: throw "makeQualifiers: unmatched FormatSpecifier <specifier>";
		}
	}
}

private list[Expression] makeExpressionList({ Expression "," }+ expressions) {
	return for (expression <- expressions) append makeExpression(expression);
}

private Expression makeExpression(lang::derric::Syntax::Expression expression) {
	switch (expression) {
		case (Expression)`(<lang::derric::Syntax::Expression e>)`: return makeExpression(e);
		case (Expression)`<Number n>`: return \value(makeInt(n));
		case (Expression)`<String s>`: return \value(makeString(s));
		case (Expression)`<Id i>`: return ref("<i>");
		case (Expression)`<Id i> . <Id j>`: return ref("<i>", "<j>");
		case `<lang::derric::Syntax::Expression l> ^ <lang::derric::Syntax::Expression r>`: return pow(makeExpression(l), makeExpression(r));
		case `<lang::derric::Syntax::Expression l> + <lang::derric::Syntax::Expression r>`: return add(makeExpression(l), makeExpression(r));
		case `<lang::derric::Syntax::Expression l> - <lang::derric::Syntax::Expression r>`: return minus(makeExpression(l), makeExpression(r));
		case `<lang::derric::Syntax::Expression l> * <lang::derric::Syntax::Expression r>`: return times(makeExpression(l), makeExpression(r));
		case `<lang::derric::Syntax::Expression l> / <lang::derric::Syntax::Expression r>`: return divide(makeExpression(l), makeExpression(r));
		case `lengthOf ( <Id i> )`: return lengthOf("<i>");
		case `lengthOf ( <Id i> . <Id j> )`: return lengthOf("<i>", "<j>");
		case `offset ( <Id i> )`: return offset("<i>");
		case `offset ( <Id i> . <Id j> )`: return offset("<i>", "<j>");
		case `<lang::derric::Syntax::Expression l> .. <lang::derric::Syntax::Expression r>`: return range(makeExpression(l), makeExpression(r));
		case `<lang::derric::Syntax::Expression l> | <lang::derric::Syntax::Expression r>`: return or(makeExpression(l), makeExpression(r));
		case `! <lang::derric::Syntax::Expression e>`: return not(makeExpression(e));
		case `- <lang::derric::Syntax::Expression e>`: return negate(makeExpression(e));
	}
}

private int makeInt(Number n) {
	s = "<n>";
	if (startsWith(s, "0x") || startsWith(s, "0X")) return toInt(substring(s, 2), 16); 
	else if (startsWith(s, "0o") || startsWith(s, "0O")) return toInt(substring(s, 2), 8); 
	else if (startsWith(s, "0b") || startsWith(s, "0B")) return toInt(substring(s, 2), 2);
	else return toInt(s); 
}

private str makeString(String s) {
	return substring("<s>", 1, size("<s>")-1);
}
