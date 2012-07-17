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
import Message;

import lang::derric::FileFormat;

public set[Message] check(FileFormat f) = checkUndefinedSequenceNames(f) + checkDuplicateNames(f) + checkUndefinedSourceNames(f);

private set[Message] checkDuplicateNames(FileFormat f) {
    list[Term] structureTerms = [ t | /Term t <- f.terms ];
    
    set[str] seen = {};
    set[Message] errs = {};
    
    top-down-break visit (f) {
      case Term t: {
        if (t.name in seen) {
          errs += {error("Duplicate structure name", t@location)};
        }
        else {
          seen += {t.name};
        }
        seenFields = {};
        for (Field f <- t.fields) {
          if (f.name in seenFields) {
            errs += {error("Duplicate field name", f@location)};
          }
          else {
            seenFields += {f.name};
          }
        }
      }
    }
    return errs;
}



private set[Message] checkUndefinedSequenceNames(FileFormat f) {
	set[str] structureNames = { t.name | /Term t <- f.terms };
	return { error("Undefined structure", t@location) | /t:term(str name) <- f.sequence, name notin structureNames };
}

private set[Message] checkUndefinedSourceNames(FileFormat f) {
	set[str] structureNames = { t.name | /Term t <- f.terms };
	return { error("Undefined structure", t@location) | /term(_, str s, _) <- f.terms, s notin structureNames };
}

