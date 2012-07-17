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

module lang::derric::OutlineFormat

import lang::derric::FileFormat;

import util::IDE; // outline annos

public node outline(t:format(str name, _, _, seq, trms)) = "format"(
  "seq"([ outlineSym(s) | s <- seq])[@label="Sequence"],
  "trms"([ outline(trm) | trm <- trms])[@label="Structures"]
)[@label="Format <name>"][@\loc=t@location];

public node outline(Term t) = "struct"([outline(f) | f <- t.fields])[@label=t.name][@\loc=t@location];
public node outline(Field fld) = "fld"()[@label=fld.name][@\loc=fld@location];

public node outlineSym(Symbol t) {
  switch (t) {
    case term(str n): return "sym"()[@label=n][@\loc=t@location];
    case not(Symbol s): return "not"(outlineSym(s))[@label="Not"][@\loc=t@location];
    case optional(Symbol s): return "opt"(outlineSym(s))[@label="Optional"][@\loc=t@location];
    case iter(Symbol s): return "iter"(outlineSym(s))[@label="Repeated"][@\loc=t@location];
    case anyOf(set[Symbol] ss): return "any"([ outlineSym(s) | s <- ss ])[@label="Any of"][@\loc=t@location];
    case seq(list[Symbol] ss): return "seq"([ outlineSym(s) | s <- ss ])[@label="Sequence"][@\loc=t@location];
    default: throw "Unsupported symbol: <t>";
  }
}



// this does not work...
//public node outlineSym(t:Symbol::term(str n)) = "sym"()[@label=n][@\loc=t@location];
//public node outlineSym(t:Symbol::optional(Symbol s)) = "opt"(outlineSym(s))[@label="Optional"][@\loc=t@location];
//public node outlineSym(t:Symbol::iter(Symbol s)) = "iter"(outlineSym(s))[@label="Repeated"][@\loc=t@location];
//public node outlineSym(t:Symbol::anyOf(set[Symbol] ss)) = "any"([ outlineSym(s) | s <- ss ])[@label="Any of"][@\loc=t@location];
//public node outlineSym(t:Symbol::seq(set[Symbol] ss)) = "seq"([ outlineSym(s) | s <- ss ])[@label="Sequence"][@\loc=t@location];
