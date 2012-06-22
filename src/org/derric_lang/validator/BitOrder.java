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

public enum BitOrder {
	MSB_FIRST {
		public void apply(byte[] b) {
		}

		public byte apply(byte b) {
			return b;
		}
	},
	LSB_FIRST {
		public void apply(byte[] b) {
			for (int i = 0; i < b.length; i++) {
				b[i] = apply(b[i]);
			}
		}

		public byte apply(byte b) {
			// see: http://graphics.stanford.edu/~seander/bithacks.html#ReverseByteWith64BitsDiv
			return (byte) (((b & 0xFF) * 0x0202020202L & 0x010884422010L) % 1023);
		}
	};

	public abstract void apply(byte[] b);
	public abstract byte apply(byte b);
}
