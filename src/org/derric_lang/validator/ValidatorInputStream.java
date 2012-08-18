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
import java.io.InputStream;
import java.util.List;
import java.util.Map;

public abstract class ValidatorInputStream extends InputStream {

  public abstract boolean isByteAligned();
  public abstract boolean atEOF() throws IOException;

  public abstract long lastLocation();
	public abstract long lastRead();
	public abstract void mark();
	public abstract void reset() throws IOException;

	public abstract boolean skipBits(long bits) throws IOException;
	public abstract long skip(long bytes) throws IOException;

	public abstract ValidatorInputStream bitOrder(BitOrder order);
	public abstract ValidatorInputStream byteOrder(ByteOrder order);
	public abstract ValidatorInputStream signed();
	public abstract ValidatorInputStream unsigned();
	public abstract long readInteger(long bits) throws IOException;

	public abstract ValidatorInputStream includeMarker(boolean includeMarker);
	public abstract Content readUntil(long bits, ValueSet values) throws IOException;

	public abstract Content validateContent(long size, String name, Map<String, String> configuration, Map<String, List<Object>> arguments, boolean allowEOF) throws IOException;
}
