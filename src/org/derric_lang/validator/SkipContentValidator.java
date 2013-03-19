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
import java.util.List;
import java.util.Map;

public class SkipContentValidator implements ContentValidator {

  @Override
  public Content validateContent(ValidatorInputStream in, long size, String name, Map<String, String> configuration, Map<String, List<Object>> arguments, boolean allowEOF) throws IOException {
    if (arguments.containsKey("terminator") && arguments.containsKey("terminatorsize") && configuration.containsKey("includeterminator")) {
      ValueSet terminators = new ValueSet();
      List<Object> lt = arguments.get("terminator");
      for (Object i : lt) {
        terminators.addEquals(((Long) i).longValue());
      }
      int terminatorSize = ((Long) arguments.get("terminatorsize").get(0)).intValue();
      boolean includeTerminator = configuration.get("includeterminator").toLowerCase().equals("true") ? true : false;
      Content content = in.includeMarker(includeTerminator).readUntil(terminatorSize, terminators);
      return new Content (content.validated || allowEOF, content.data);
    } else if (size >= 0) {
      if (in.available() == 0) {
        return new Content(false, new byte[0]);
      } else if (in.available() < size) {
        int available = in.available();
        byte[] data = new byte[available];
        in.read(data);
        return new Content(false, data);
      } else {
        byte[] data = new byte[(int) size];
        int read = in.read(data);
        return new Content((read == size) || allowEOF, data);
      }
    } else {
      throw new RuntimeException("Either the field's size must be defined or a terminator and terminatorsize must be provided.");
    }
  }
}
