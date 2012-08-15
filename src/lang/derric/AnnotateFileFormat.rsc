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

module lang::derric::AnnotateFileFormat

import IO;
import List;
import Set;

import lang::derric::FileFormat;

anno bool Symbol @ allowEOF;

data Reference = local() | global();
data Dependency = dependency(str name);
anno Reference Field @ ref;
anno Reference Field @ size;
anno Dependency Field @ refdep;
anno Dependency Field @ sizedep;

public FileFormat annotate(FileFormat format) {
	return annotateSymbols(annotateFieldReferences(format));
}

public FileFormat annotateSymbols(FileFormat format) {
	bool allowEOF = true;
	for (i <- [size(format.sequence)-1..0]) {
		if (anyOf(set[Symbol] symbols) := format.sequence[i]) {
			if (seq([]) notin symbols) {
				allowEOF = false;
			}
		}
		format.sequence[i]@allowEOF = allowEOF;
	}
	return format;
}

public FileFormat annotateFieldReferences(FileFormat format) {
	rel[str, str, Reference] refenv = makeReferenceEnvironment(format, true);
	rel[str, str, Reference] sizeenv = makeReferenceEnvironment(format, false);
	rel[str, str, Dependency] refdepenv = makeDependencyEnvironment(format, true);
	rel[str, str, Dependency] refsizeenv = makeDependencyEnvironment(format, false);
	str sname = "";
	return top-down visit (format) {
		case term(str name, _): sname = name;
		case f:field(str name, _, _, _): {
			set[Reference] annotation = refenv[sname, name];
			if (size(annotation) == 1) {
				//println("Adding value reference to <sname>.<name>");
				f@ref = getOneFrom(annotation);
			}
			annotation = sizeenv[sname, name];
			if(size(annotation) == 1) {
				//println("Adding size reference to <sname>.<name>");
				f@size = getOneFrom(annotation);
			}
			set[Dependency] dependency = refdepenv[sname, name];
			if (size(dependency) == 1) {
				//println("Adding local forward value reference to <sname>.<name>")
				f@refdep = getOneFrom(dependency);
			}
			dependency = refsizeenv[sname, name];
			if (size(dependency) == 1) {
				//println("Adding local forward size reference to <sname>.<name>");
				f@sizedep = getOneFrom(dependency);
			}
			insert f;
		}
	}
}

private rel[str, str, Reference] makeReferenceEnvironment(FileFormat format, bool values) {
	rel[str struct, str field, Reference ref] env = {};
	rel[str struct, str field, bool seen] order = {};
	str sname = "";
	str fname = "";
	
	void makeRef(str struct, str name) {
		if (struct != sname) {
			//println("<struct>.<name> is referenced globally.");
			env += <struct, name, global()>;
		} else if (!isEmpty(order[sname, name])) {
			//println("<sname>.<name> is referenced locally.");
			env += <sname, name, local()>;
		}
	}

	top-down visit (format) {
		case term(str name, _): sname = name;
		case field(str name, _, _, _): {
			fname = name;
			order += <sname, fname, true>;
		}
		case ref(str struct, str name): if (values) makeRef(struct, name);
		case lengthOf(str struct, str name): if (!values) makeRef(struct, name);
		case ref(str name): if (values) makeRef(sname, name);
		case lengthOf(str name): if (!values) makeRef(sname, name);
		case field(str struct, str name): if (values) makeRef(struct, name);
		case field(str name): if (values) makeRef(sname, name);
	}
	return env;
}

private rel[str, str, Dependency] makeDependencyEnvironment(FileFormat format, bool values) {
	rel[str struct, str field, str dep] env = {};
	rel[str struct, str field, int count] order = {};
	rel[str struct, str field, Dependency dep] deps = {};
	str sname = "";
	str fname = "";
	int count = 0;
	
	void makeRef(str struct, str name) {
		if (struct == sname && isEmpty(order[sname, name])) {
			//println("<sname>.<name> has a local forward reference.");
			env += <sname, fname, name>;
		}
	}

	top-down visit (format) {
		case term(str name, _): {
			sname = name;
			count = 0;
		}
		case field(str name, _, _, _): {
			fname = name;
			order += <sname, fname, count>;
			count += 1;
		}
		case ref(str struct, str name): if (values) makeRef(struct, name);
		case lengthOf(str struct, str name): if (!values) makeRef(struct, name);
		case ref(str name): if (values) makeRef(sname, name);
		case lengthOf(str name): if (!values) makeRef(sname, name);
		case field(str struct, str name): if (values) makeRef(struct, name);
		case field(str name): if (values) makeRef(sname, name);
	}
	for (<str struct, str field> <- env<0, 1>) {
		//println("<struct>.<field>");
		//println("order: <order>");
		//println("env: <env>");
		int max = max(order[struct, env[struct, field]]);
		Dependency dep = dependency([v | t <- order, <struct, str v, max> := t][0]);
		deps += <struct, field, dep>;
	}
	return deps;
}
