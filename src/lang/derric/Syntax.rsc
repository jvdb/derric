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

module lang::derric::Syntax

layout LAYOUTLIST = LAYOUT* !>> [\t-\n \r \ ];
lexical LAYOUT = whitespace: [\t-\n \r \ ] | Comment;

keyword DerricKeywords =
   "format"
 | "extension"
 | "sequence"
 | "structures"
 | "unit" | "sign" | "endian" | "strings" | "type"
 | "big" | "little" | "true" | "false" | "byte" | "bit" | "ascii" | "utf8" | "integer" | "float" | "string"
 | "size"
 | "expected" | "terminatedBefore" | "terminatedBy"
 | "lengthOf" | "offset";

lexical Id = ([a-z A-Z _] !<< [a-z A-Z _][a-z A-Z 0-9 _]* !>> [a-z A-Z 0-9 _]) \ DerricKeywords;
lexical ContentSpecifierId = @category="Todo" Id;
lexical ExpressionId = @category="Identifier" Id id;
lexical Number = @category="Constant" hex: [0][xX][a-f A-F 0-9]+ !>> [a-f A-F 0-9]
              |  @category="Constant" bin: [0][bB][0-1]+ !>> [0-1]
              |  @category="Constant" oct: [0][oO][0-7]+ !>> [0-7]
              |  @category="Constant" dec: [0-9]+ !>> [0-9];
lexical String = @category="Constant" "\"" ![\"]*  "\"";
lexical Comment = @category="Comment" "/*" CommentChar* "*/";
lexical CommentChar = ![*] | [*] !>> [/];

start syntax Format = @Foldable "format" Id "extension" Id+ Defaults Sequence seq Structures structs;

syntax Defaults = @Foldable FormatSpecifier*;
syntax FormatSpecifier = FixedFormatSpecifierKeyword FixedFormatSpecifierValue
                       | VariableFormatSpecifierKeyword Expression;
syntax FixedFormatSpecifierKeyword = "unit" | "sign" | "endian" | "strings" | "type";
syntax FixedFormatSpecifierValue = "big" | "little"
                                 | "true" | "false"
                                 | "byte" | "bit"
                                 | "ascii" | "utf8"
                                 | "integer" | "float" | "string";
syntax VariableFormatSpecifierKeyword = "size";

syntax Sequence = @Foldable "sequence" SequenceSymbol*;
syntax SequenceSymbol = "(" SequenceSymbol+ ")"
                      | "[" SequenceSymbol* "]"
                      | right "!" SequenceSymbol
                      > SequenceSymbol "*"
                      | SequenceSymbol "?"
                      | struct: Id;

syntax Structures = @Foldable "structures" Structure*;
syntax Structure = @Foldable StructureHead head "{" Field* fields "}";
syntax StructureHead = Id name
                     | Id name "=" Id super;
syntax Field = Id name ":" FieldSpecifier spec ";"
             | Id name ";"
             | Id name ":" "{" Field* "}";
syntax FieldSpecifier = ValueListSpecifier FormatSpecifier*
                      | FormatSpecifier+;
syntax ValueListSpecifier = ValueModifier* { Expression "," }+
                          | ValueModifier* ContentSpecifier;
syntax ValueModifier = "expected" | "terminatedBefore" | "terminatedBy";
syntax ContentSpecifier = ContentSpecifierId "(" { ContentModifier "," }* ")";
syntax ContentModifier = Id "=" { Argument "+" }+;
syntax Argument = String
				| Number
				| Id
				| Id "." Id;

syntax Expression = Num: Number
                  | Str: String
                  | Ref: ExpressionId
                  | ExtRef: ExpressionId "." ExpressionId
                  | Bracket: "(" { Expression "," }+ ")"
                  | LocalCall: BuiltIn "(" ExpressionId ")"
                  | GlobalCall: BuiltIn "(" ExpressionId "." ExpressionId ")"
                  | Neg: "-" Expression
                  | Not: "!" Expression 
                  > left Pow: Expression "^" Expression
                  > left ( Mul: Expression "*" Expression
                         | Div: Expression "/" Expression)
                  > left ( Add: Expression "+" Expression
                         | Sub: Expression "-" Expression)
                  > non-assoc Range: Expression ".." Expression
                  > left Or: Expression "|" Expression;

syntax BuiltIn = "lengthOf" | "offset";
