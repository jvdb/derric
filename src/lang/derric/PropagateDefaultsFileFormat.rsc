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

module lang::derric::PropagateDefaultsFileFormat

import lang::derric::FileFormat;

anno bool Qualifier @ local;

public FileFormat propagateDefaults(FileFormat format) {
	list[Qualifier] baseDefaults = getDefaultQualifiers();
	format.defaults = resolveOverrides(baseDefaults, format.defaults, false);
	return visit (format) {
		case f:field(_, _, _, _) => resolveFieldOverrides(format, f)
	}
}

public list[Qualifier] getDefaultQualifiers() {
	return [unit("byte"), sign(false), endian("big"), strings("ascii"), \type("integer"), size(\value(1))];
}

private Field resolveFieldOverrides(FileFormat format, Field field) {
	field.qualifiers = resolveOverrides(format.defaults, field.qualifiers, true);
	return field;
}

private list[Qualifier] resolveOverrides(list[Qualifier] base, list[Qualifier] override, bool tagLocal) {
	for (q <- override) {
		int id = 6;
		switch(q) {
			case u:unit(str name): {
				id = 0;
				base[id] = u;
			}
			case s:sign(bool present): {
				id = 1;
				base[id] = s;
			}
			case e:endian(str name): {
				id = 2;
				base[id] = e;
			}	
			case s:strings(str encoding): {
				id = 3;
				base[id] = s;
			}	
			case t:\type(str name): {
				id = 4;
				base[id] = t;
			}	
			case s:size(Expression count): {
				id = 5;
				base[id] = s;
			}	
		}
		if (id < 6 && tagLocal) {
			base[id]@local = true;
		}
	}
	return base;
}
