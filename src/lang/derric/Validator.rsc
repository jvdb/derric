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

module lang::derric::Validator

import lang::derric::FileFormat;

data Validator =
  validator(str name, str format, list[Global] globals, list[Structure] structs);

data Global =
  gdeclV(Type \type, str name)
| gdeclB(str name);

data Structure =
  structure(str name, list[Statement] statements);

data Statement =
  ldeclV(Type \type, str name)
| ldeclB(str name)
| calc(str varName, VExpression exp)
| readValue(Type \type, str varName)
| readBuffer(str sizeVar, str varName)
| readUntil(Type \type, list[VExpression] expOptions, bool includeMarker)
| skipValue(Type \type)
| skipBuffer(str sizeVar)
| validate(str varName, list[VExpression] expOptions)
| validateContent(str varName, str lenName, str method, map[str, str] custom, map[str, list[VExpression]] references, bool allowEOF);

data VExpression =
  var(str name)
| con(int intValue)
//| con(real realValue)
| sub(VExpression lhs, VExpression rhs)
| add(VExpression lhs, VExpression rhs)
| fac(VExpression lhs, VExpression rhs)
| div(VExpression lhs, VExpression rhs)
| pow(VExpression base, VExpression exp)
| neg(VExpression exp)
| not(VExpression exp)
| range(VExpression lower, VExpression upper);

data Type =
  integer(bool sign, Endianness endian, int bits)
| float(Endianness endian, int bits);

data Endianness =
  little()
| big();

anno loc Validator@location;
anno loc Global@location;
anno loc Structure@location;
anno loc Statement@location;
anno loc VExpression@location;
anno loc Type@location;
anno loc Endianness@location;

anno str Statement@fieldName;
anno str Global@fieldName;
