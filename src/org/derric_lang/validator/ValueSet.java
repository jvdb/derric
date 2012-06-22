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

import java.util.ArrayList;

public class ValueSet implements ValueComparer {

	private ArrayList<ValueComparer> _values = new ArrayList<ValueComparer>();

	public void addEquals(long value) {
		_values.add(new Value(value, true));
	}

	public void addNot(long value) {
		_values.add(new Value(value, false));
	}

	public void addEquals(long lower, long upper) {
		_values.add(new Range(lower, upper, true));
	}

	public void addNot(long lower, long upper) {
		_values.add(new Range(lower, upper, false));
	}

	@Override
	public boolean equals(long value) {
		for (ValueComparer vc : _values) {
			if (vc.equals(value))
				return true;
		}
		return false;
	}

	class Value implements ValueComparer {
		public long value;
		public boolean equals;

		public Value(long value, boolean equals) {
			this.value = value;
			this.equals = equals;
		}

		@Override
		public boolean equals(long value) {
			return (this.value == value) == equals;
		}
	}

	class Range implements ValueComparer {
		public long lower;
		public long upper;
		public boolean equals;

		public Range(long lower, long upper, boolean equals) {
			this.lower = lower;
			this.upper = upper;
			this.equals = equals;
		}

		@Override
		public boolean equals(long value) {
			return (lower <= value && upper >= value) == equals;
		}
	}
}
