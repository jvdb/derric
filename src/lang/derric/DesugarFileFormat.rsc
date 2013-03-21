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

module lang::derric::DesugarFileFormat

import IO;
import Set;
import List;
import String;
import analysis::graphs::Graph;

import lang::derric::FileFormat;
import lang::derric::Strings;

public FileFormat desugar(FileFormat format) {
	return normalizeSequence(removeNot(removeOffset(fixLengthOf(removeStrings(removeMultipleExpressions(removeInheritance(format)))))));
}

private FileFormat removeInheritance(FileFormat format) {
	rel[str, str, list[Field]] env = { };
	for (t <- format.terms) {
		if (term(str name, str source, list[Field] fields) := t) { env += <name, source, fields>; }
		else { env += <t.name, "", t.fields>; }
	}

	str sname;
	rel[str struct, int order, str field, str repl] replacements = { };
	list[Field] expandMultipleFields(list[Field] fields) {
		return ret:for (f <- fields) {
			if (field(str n, list[Field] fs) := f) {
				int i = 0;
				for (fi <- fs) {
					replacements += <sname, i, n, fi.name>;
					i += 1;
				}
				expandMultipleFields(fs);
			} else append ret: f;
		}
	}

	list[Field] merge(str name) {
		list[Field] currentFields = getOneFrom(env[name,_]);
		rel[str n, list[Field] fl] base = env[name]; 
		list[Field] baseFields = [];
		if (getOneFrom(base.n) != "") {
			baseFields = merge(getOneFrom(base.n));
		}
		
		overriddenFields = top:for (baseField <- baseFields) {
			bool overridden = false;
			 for (currentField <- currentFields) {
				if (baseField.name == currentField.name) {
					overridden = true;
					append top: currentField;
				}
			}
			if (!overridden) {
				append top: baseField;
			}
		}
		return expandMultipleFields(overriddenFields + (currentFields - overriddenFields));
	}

	format.terms = for (t <- format.terms) {
		if (term(str name, str source, list[Field] fields) := t) {
			sname = name;
			append term(name, merge(name))[@location=t@location];
		} else {
			append t;
		}
	}
	
	str resolveOffset(str struct, str name) {
		set[str] override = (replacements[struct, 0]+)[name] & bottom(replacements[struct, 0]+);
		if (isEmpty(override)) {
			return name;
		} else {
			return getOneFrom(override);
		}
	}
	
	Expression resolveLength(str struct, str name, bool local, loc l) {
		set[str] override = (replacements[struct, _]+)[name] & bottom(replacements[struct, _]+);
		if (isEmpty(override)) {
			if (local) return lengthOf(name)[@location=l];
			else return lengthOf(struct, name)[@location=l];
		} else {
			list[str] names = toList(override);
			tuple[str head, list[str] tail] result = pop(toList(override));
			return expandLengthOf(struct, result.head, result.tail, local, l);
		}
	}
	
	list[Specification] resolveSpecification(str sname, list[Specification] ls) {
		return top:for (Specification spec <- ls) {
			if (const(_) := spec) {
				append spec;
			} else {
				if (field(str struct, str name) := spec) {
					list[str] overrides = [ n | <i, n> <- sort([*(replacements<0,2,1,3>[struct,name])]), n in bottom(replacements[struct,_]+)];
					if (isEmpty(overrides)) {
						append top:field(struct, name)[@location=spec@location];
					} else {
						for (str n <- overrides) {
							append top:field(struct, n)[@location=spec@location];
						}
					}
				} else if (field(str name) := spec) {
					list[str] overrides = [ n | <i, n> <- sort([*(replacements<0,2,1,3>[sname,name])]), n in bottom(replacements[sname,_]+)];
					if (isEmpty(overrides)) {
						append top:field(name)[@location=spec@location];
					} else {
						for (str n <- overrides) {
							append top:field(n)[@location=spec@location];
						}
					}
				}
			}
		}
	}

	return top-down visit (format) {
		case term(str name, list[Field] fields): sname = name;
		case f:offset(str name) => offset(resolveOffset(sname, name))[@location=f@location]
		case f:offset(str struct, str name) => offset(struct, resolveOffset(struct, name))[@location=f@location]
		case l:lengthOf(str name) => resolveLength(sname, name, true, l@location)
		case l:lengthOf(str struct, str name) => resolveLength(struct, name, false, l@location)
		case tuple[str n, list[Specification] ls] t => <t.n, resolveSpecification(sname, t.ls)>
	}
}

private FileFormat removeMultipleExpressions(FileFormat format) {
	list[Field] expandMultipleExpressions(list[Field] fields) {
		return ret:for (f <- fields) {
			if (field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, list[Expression] specifications) := f) {
				for (i <- [1..size(specifications)]) {
					str fname = name;
					if (i > 1) fname = name + "*<i>";
					append ret: field(fname, modifiers, qualifiers, specifications[i-1])[@location=f@location];
				}
			} else append f;
		}
	}

	return visit (format) {
		case t:term(str name, list[Field] fields) => term(name, expandMultipleExpressions(fields))[@location=t@location]
	}
}

private FileFormat removeStrings(FileFormat format) {
	rel[str sname, str name, int count] expandedStrings = {};
	str sname;
	list[Field] expandStrings(str sname, list[Field] fields) {
		return ret:for (f <- fields) {
			if (field(str name, list[Modifier] modifiers, list[Qualifier] qualifiers, \value(str v)) := f) {
				qualifiers[0].name = "byte";
				qualifiers[1].present = false;
				qualifiers[4].\type = "integer";
				qualifiers[5].count = \value(1);
				int count = 0;
				for (i <- [0..size(v)-1]) {
					str fname = name;
					if (i > 0) fname = name + "*s<i>";
					append ret: field(fname, modifiers, qualifiers, \value(ascii[v[i]]))[@location=f@location];
					count += 1;
				}
				expandedStrings += <sname, name, count-1>;
			} else append f;
		}
	}
	
	list[Specification] expandSpecification(list[Specification] ls) {
		return top:for (spec <- ls) {
			if (field(str fsname, str fname) := spec) {
				if (!isEmpty(expandedStrings[fsname, fname])) {
					append top:spec;
					for (i <- [1..getOneFrom(expandedStrings[fsname, fname])]) {
						append top:field(fsname, fname + "*s<i>")[@location=spec@location];
					}
				} else {
					append top:spec;
				}
			} else if (field(str fname) := spec) {
				if (!isEmpty(expandedStrings[sname, fname])) {
					append top:spec;
					for (i <- [1..getOneFrom(expandedStrings[sname, fname])]) {
						append top:field(fname + "*s<i>")[@location=spec@location];
					}
				} else {
					append top:spec;
				}
			} else {
				append top:spec;
			}
		}
	}

	expanded = visit (format) {
		case t:term(str name, list[Field] fields) => term(name, expandStrings(name, fields))[@location=t@location]
	}

	return top-down visit (expanded) {
		case term(str name, _): sname = name;
		case tuple[str n, list[Specification] ls] t => <t.n, expandSpecification(t.ls)>
	}
}

private FileFormat fixLengthOf(FileFormat format) {
	rel[str sname, str fname, str mname] env = { };
	for (t <- format.terms, f <- t.fields) {
		switch (f) {
			case field(str mname, _, _, _):
				if (/<name:.*?>\*.*/ := mname) {
					env +=  < t.name, name, mname >;
				}
		}
	}
	//println("env: <env>");

	return top-down-break visit (format) {
		case t:term(str sname, list[Field] fields): {
			fs = top-down-break visit (fields) {
				case l:lengthOf(str name) => expandLengthOf(sname, name, toList(env[sname,name]), true, l@location)
				case l:lengthOf(str struct, str name) => expandLengthOf(struct, name, toList(env[struct,name]), false, l@location)
			}
			insert term(sname, fs)[@location=t@location];
		}
	}
}

private FileFormat removeOffset(FileFormat format) {
	list[Field] fields = [];
	str sname;
	return top-down visit (format) {
		case term(str name, list[Field] fs): {
			fields = fs;
			sname = name;
		}
		case f:offset(str name): {
			list[str] preceders = getPrecedingFieldNames(name, fields);
			if (isEmpty(preceders)) insert \value(0)[@location=f@location];
			else {
				tuple[str head, list[str] tail] result = pop(preceders);
				insert expandLengthOf(sname, result.head, result.tail, true, f@location);
			}
		}
		case f:offset(str struct, str name): {
			list[str] preceders = getPrecedingFieldNames(name, getFields(format, struct));
			if (isEmpty(preceders)) insert \value(0)[@location=f@location];
			else {
				tuple[str head, list[str] tail] result = pop(preceders);
				insert expandLengthOf(struct, result.head, result.tail, false, f@location);
			}
		}
	}
}

private list[Field] getFields(FileFormat format, str struct) {
	for (term <- format.terms) {
		if (term.name == struct) return term.fields;
	}
}

private Expression expandLengthOf(str struct, str head, list[str] tail, bool local, loc l) {
	//println("expanding <struct>.<head> (tail: <tail>, local: <local>)");
	if (isEmpty(tail)) {
		if (local) return lengthOf(head)[@location=l];
		else return lengthOf(struct, head)[@location=l];
	}
	tuple[str h,list[str] t] r = takeOneFrom(tail);
	if (local) return add(lengthOf(head)[@location=l],expandLengthOf(struct, r.h, r.t, local, l))[@location=l];
	else return add(lengthOf(struct, head),expandLengthOf(struct, r.h, r.t, local, l))[@location=l];
}

private list[str] getPrecedingFieldNames(str name, list[Field] fields) {
	bool seen = false;
	return for (Field field <- fields) {
		if (field.name == name) seen = true;
		if (!seen && field.name != name) append field.name;
	}
}

private FileFormat removeNot(FileFormat format) {
	return visit (format) {
		case n:not(t:term(str name)) => invert(format, {t})[@location=n@location]
		case n:not(anyOf(set[Symbol] symbols)) => invert(format, symbols)[@location=n@location]
	}
}

public Symbol invert(FileFormat format, set[Symbol] symbols) {
	exclude = for (term(str n) <- symbols) {
		append n;
	}
	include = for (t:term(str n, _) <- format.terms) {
		if (!(n in exclude)) {
			append term(n)[@location=t@location];
		}
	}
	return size(include) > 1 ? anyOf(toSet(include)) : include[0];
}

private FileFormat normalizeSequence(FileFormat format) {
	return top-down-break visit (format) {
			case t:term(str name) => anyOf({seq([term(name)[@location=t@location]])[@location=t@location]})[@location=t@location]
			case p:optional(t:term(str name)) => anyOf({seq([term(name)[@location=t@location]])[@location=p@location], seq([])[@location=p@location]})[@location=p@location]
			case i:iter(t:term(str name)) => iter(anyOf({seq([term(name)[@location=t@location]])})[@location=i@location])[@location=i@location]
			case a:anyOf(set[Symbol] symbols) => anyOf({ seq([s])[@location=s@location] | s <- symbols, !(seq(list[Symbol] syms) := s)} + { s | s <- symbols, seq(list[Symbol] syms) := s})[@location=a@location]
			case i:iter(a:anyOf(set[Symbol] symbols)) => iter(anyOf({ seq([s])[@location=s@location] | s <- symbols, !(seq(list[Symbol] syms) := s)} + { s | s <- symbols, seq(list[Symbol] syms) := s})[@location=a@location])[@location=i@location]
			case s:seq(list[Symbol] symbols) => anyOf({seq(symbols)[@location=s@location]} + { s | s <- symbols, seq(list[Symbol] syms) := s})[@location=s@location]
			case i:iter(s:seq(list[Symbol] symbols)) => iter(anyOf({seq(symbols)[@location=s@location]})[@location=i@location])[@location=i@location]
			case p:optional(s:seq(list[Symbol] symbols)) => anyOf({seq(symbols)[@location=s@location], seq([])[@location=p@location]})[@location=p@location]
			case p:optional(a:anyOf(set[Symbol] symbols)) => anyOf({ seq([s])[@location=s@location] | s <- symbols, !(seq(list[Symbol] syms) := s)} + { s | s <- symbols, seq(list[Symbol] syms) := s} + {seq([])[@location=p@location]})[@location=a@location]
	}
}
