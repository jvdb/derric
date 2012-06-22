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

module lang::derric::CheckFileFormat

import IO;
import List;
import Map;

import lang::derric::FileFormat;

data CheckResult = error(str message);

public list[CheckResult] check(FileFormat f) {
	return checkUndefinedSequenceNames(f) + checkDuplicateStructureNames(f) + checkUndefinedSourceNames(f) + checkDuplicateFieldNames(f);
}

private list[CheckResult] checkDuplicateStructureNames(FileFormat f) {
	list[str] structureNames = [ name | /term(str name, list[Field] _) <- f.terms ] + [ name | /term(str name, str source, list[Field] _) <- f.terms ];
	if (isEmpty(structureNames)) return [];
	list[str] duplicates = findDuplicates(takeOneFrom(structureNames), []);
	return for (str s <- duplicates) {
		append error("Structure name not unique: " + s);
	}
}

private list[str] findDuplicates(tuple[str item, list[str] master] t, list[str] duplicates) {
	if (isEmpty(t.master)) return duplicates;
	if (t.item in toSet(t.master)) return findDuplicates(takeOneFrom(t.master), duplicates + t.item);
	else return findDuplicates(takeOneFrom(t.master), duplicates);
}

private list[CheckResult] checkUndefinedSequenceNames(FileFormat f) {
	set[str] structureNames = { name | /term(str name, list[Field] _) <- f.terms } + { name | /term(str name, str source, list[Field] _) <- f.terms };
	set[str] sequenceNames = { name | /term(str name) <- f.sequence };
	set[str] undefinedReferencedNames = sequenceNames - structureNames;
	return for (str s <- undefinedReferencedNames) {
		append error("Sequence references undefined structure: " + s);
	}
}

private list[CheckResult] checkUndefinedSourceNames(FileFormat f) {
	set[str] structureNames = { name | /term(str name, list[Field] _) <- f.terms } + { name | /term(str name, str source, list[Field] _) <- f.terms };
	set[str] sourceNames = { source | /term(str name, str source, list[Field] _) <- f.terms };
	set[str] undefinedSourceNames = sourceNames - structureNames;
	return for (str s <- undefinedSourceNames) {
		append error("Undefined structure referenced as source: " + s);
	}
}

private list[CheckResult] checkDuplicateFieldNames(FileFormat ff) {
	return for (Term t <- ff.terms, !isEmpty(t.fields), str s <- findDuplicates(takeOneFrom([f.name | Field f <- t.fields]), [])) {
		append error("Field name not unique: " + t.name + "." + s);
	}
}
