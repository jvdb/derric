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

module lang::derric::PropagateConstantsFileFormat

import IO;
import Set;

import lang::derric::FileFormat;

data EType = v(Expression e) | s(Expression e);

public bool isConst(\value(int i)) = true;
public default bool isConst(Expression e) = false;

public FileFormat propagateConstants(FileFormat format) {
	rel[str sname, str fname, EType etype] env = makeEnvironment(format);
	
	EType propagate(str sname, EType etype) {
		return visit(etype) {
			case ref(str name): {
				consts = { si | v(si) <- env[sname,name], isConst(si) };
				if (size(consts) == 1) insert(getOneFrom(consts));
			}
			case ref(str struct, str name): {
				consts = { si | v(si) <- env[struct,name], isConst(si) };
				if (size(consts) == 1) insert(getOneFrom(consts));
			}
			case lengthOf(str name): {
				consts = { si | s(si) <- env[sname,name], isConst(si) };
				if (size(consts) == 1) insert(getOneFrom(consts));
			}
			case lengthOf(str struct, str name): {
				consts = { si | s(si) <- env[struct,name], isConst(si) };
				if (size(consts) == 1) insert(getOneFrom(consts));
			}
		}
	}

	EType fold(EType etype) {
		return bottom-up visit(etype) {
			case p:pow(\value(int b), \value(int e)) => \value(pow(b, e))[@location=p@location]
			case p:pow(pow(Expression exp, \value(int a)), \value(int b)) => pow(exp, \value(a*b))[@location=p@location]
			case m:minus(\value(int l), \value(int r)) => \value(l-r)[@location=m@location]
			case m:minus(minus(Expression exp, \value(int a)), \value(int b)) => minus(exp, \value(a+b))[@location=m@location]
			case m:minus(minus(\value(int a), Expression exp), \value(int b)) => minus(\value(a-b), exp)[@location=m@location]
			case m:minus(\value(int a), minus(Expression exp, \value(int b))) => minus(\value(a+b), exp)[@location=m@location]
			case m:minus(\value(int a), minus(\value(int b), Expression exp)) => add(\value(a-b), exp)[@location=m@location]
			case t:times(\value(int l), \value(int r)) => \value(l*r)[@location=t@location]
			case t:times(times(Expression exp, \value(int a)), \value(int b)) => times(exp, \value(a*b))[@location=t@location]
			case t:times(times(\value(int a), Expression exp), \value(int b)) => times(exp, \value(a*b))[@location=t@location]
			case t:times(\value(int a), times(Expression exp, \value(int b))) => times(exp, \value(a*b))[@location=t@location]
			case t:times(\value(int a), times(\value(int b), Expression exp)) => times(exp, \value(a*b))[@location=t@location]
			case a:add(\value(int l), \value(int r)) => \value(l+r)[@location=a@location]
			case a:add(add(Expression exp, \value(int a)), \value(int b)) => add(exp, \value(a+b))[@location=a@location]
			case a:add(add(\value(int a), Expression exp), \value(int b)) => add(exp, \value(a+b))[@location=a@location]
			case a:add(\value(int a), add(Expression exp, \value(int b))) => add(exp, \value(a+b))[@location=a@location]
			case a:add(\value(int a), add(\value(int b), Expression exp)) => add(exp, \value(a+b))[@location=a@location]
			case d:divide(\value(int l), \value(int r)) => \value(l/r)[@location=d@location]
			case d:divide(divide(Expression exp, \value(int a)), \value(int b)) => divide(exp, \value(a*b))[@location=d@location]
			case d:divide(divide(\value(int a), Expression exp), \value(int b)) => divide(\value(a/b), exp)[@location=d@location]
			case d:divide(\value(int a), divide(Expression exp, \value(int b))) => divide(\value(a*b), exp)[@location=d@location]
			case d:divide(\value(int a), divide(\value(int b), Expression exp)) => times(\value(a/b), exp)[@location=d@location]
			case n:negate(\value(int v)) => \value(-v)[@location=n@location]
		}
	}

	//println("before: <env>");
	solve(env) {
		env = { < sname, fname, propagate(sname, etype) > | < sname, fname, etype > <- env };
		env = { < sname, fname, fold(etype) > | < sname, fname, etype > <- env }; 
	}
	//println("after: <env>");
	
	str sname = "";
	return top-down visit(format) {
		case term(str name, _, _): sname = name;
		case term(str name, _): sname = name;
		case f:field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, Expression specification): {
			sizeExp = { si | s(si) <- env[sname,name] };
			if (size(sizeExp) == 1) qualifiers[5].count = getOneFrom(sizeExp);
			specExp = { sp | v(sp) <- env[sname,name] };
			if (size(specExp) == 1) {
				//println("inserting <sname>.<name>: <getOneFrom(specExp)> (size=<getOneFrom(sizeExp)>)");
				insert(field(name, modifiers, qualifiers, getOneFrom(specExp)))[@location=f@location];
			}
		}
		case f:field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, ContentSpecifier specifier): {
			sizeExp = { si | s(si) <- env[sname,name] };
			if (size(sizeExp) == 1) {
				qualifiers[5].count = getOneFrom(sizeExp);
				insert(field(name, modifiers, qualifiers, specifier))[@location=f@location];
			}
		}
	}
}

private rel[str sname, str fname, EType etype] makeEnvironment(FileFormat format) {
	rel[str sname, str fname, EType etype] env = { };
	for (t <- format.terms, f <- t.fields) {
		switch(f) {
			case field(str name, _, list[Qualifier] qualifiers, Expression specification):
				env += { < t.name, name, v(specification) >, < t.name, name, s(qualifiers[5].count) > };
			case field(str name, _, list[Qualifier] qualifiers, ContentSpecifier specifier):
				env += { < t.name, name, s(qualifiers[5].count) > };
		}
	}
	
	return env;
}

private int pow(int base, int exponent) {
	if (exponent == 0) return 0;
	if (exponent == 1) return base;
	int result = base;
	while (exponent > 1) {
		result *= base;
		exponent -= 1;
	}
	return result;
}
