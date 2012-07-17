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

module lang::derric::FileFormat

import List;

data FileFormat = format(str name, list[str] extensions, list[Qualifier] defaults, list[Symbol] sequence, list[Term] terms);

data Symbol = term(str name)
	| optional(Symbol symbol)
	| iter(Symbol symbol)
	| not(Symbol symbol)
	| anyOf(set[Symbol] symbols)
	| seq(list[Symbol] symbolSequence);

data Qualifier = unit(str name)
	| sign(bool present)
	| endian(str name)
	| strings(str encoding)
	| \type(str \type)
	| size(Expression count);

data Term = term(str name, list[Field] fields)
	| term(str name, str source, list[Field] fields);

data Field = field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, list[Expression] specifications)
           | field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, Expression specification)
           | field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, ContentSpecifier specifier)
           | field(str name, list[Field] fields);

data ContentSpecifier = specifier(str name, list[tuple[str, list[Specification]]] arguments);

data Specification = const(str s)
	| const(int i)
    | field(str name)
    | field(str struct, str name);

data Modifier = required()
	| expected()
	| terminator(bool includeTerminator);

data Expression = ref(str name)
    | ref(str struct, str name)
	| not(Expression exp)
	| pow(Expression base, Expression exp)
	| minus(Expression lhs, Expression rhs)
	| times(Expression lhs, Expression rhs)
	| add(Expression lhs, Expression rhs)
	| divide(Expression lhs, Expression rhs)
	| \value(int i)
	| \value(str s)
	| lengthOf(str name)
	| lengthOf(str struct, str name)
	| offset(str name)
	| offset(str struct, str name)
	| or(Expression lhs, Expression rhs)
	| range(Expression from, Expression to)
	| negate(Expression exp)
	| noValue();
	
anno loc FileFormat@location;
anno loc Symbol@location;
anno loc Qualifier@location;
anno loc Term@location;
anno loc Field@location;
anno loc ContentSpecifier@location;
anno loc Specification@location;
anno loc Modifier@location;
anno loc Expression@location;
	