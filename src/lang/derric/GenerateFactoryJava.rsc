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

module lang::derric::GenerateFactoryJava

public str generate(rel[str, str] mapping) {
	return
"package org.derric_lang.validator.generated;

import java.util.HashMap;

import org.derric_lang.validator.Validator;

public class ValidatorFactory {

	private static HashMap\<String, Class\<? extends Validator\>\> _mapping = new HashMap\<String, Class\<? extends Validator\>\>();

	static {
		<for (<e, v> <- mapping) {
		>_mapping.put(\"<e>\", <v>.class);\n<
		}>
	}

	private ValidatorFactory() {};

	public static Validator create(String s) {
		if (!_mapping.containsKey(s)) return null;
		try {
			return _mapping.get(s).getConstructor().newInstance();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

}
";
}
