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

import java.io.IOException;
import java.util.ArrayList;

public class SubStream {
	
	public final ArrayList<byte[]> fragments = new ArrayList<byte[]>();

	public void addFragment(ValidatorInputStream stream, long size) throws IOException {
		if (!stream.isByteAligned()) {
			throw new RuntimeException("Can only read data fragments when the stream is byte aligned.");
		}
		// TODO: handle bit sizes
		byte[] data = new byte[(int)size];
		stream.read(data);
		fragments.add(data);
	}
	
	public byte[] getLast() {
		if (fragments.size() == 0) return null;
		else return fragments.get(fragments.size() -1);
	}
}
