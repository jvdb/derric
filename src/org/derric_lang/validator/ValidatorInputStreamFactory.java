/* Copyright 2011-2012 Netherlands Forensic Institute and
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
*/

package org.derric_lang.validator;

import java.net.URI;

public class ValidatorInputStreamFactory {

	private ValidatorInputStreamFactory() {
	}

	public static ValidatorInputStream create(String path) {
		return new ValidatorInputStreamImpl(new InMemoryInputStream(path), new SkipContentValidator());
	}
	
	public static ValidatorInputStream create(URI path) {
		return new ValidatorInputStreamImpl(new InMemoryInputStream(path), new SkipContentValidator());
	}
}
