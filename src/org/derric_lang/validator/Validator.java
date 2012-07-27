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

public abstract class Validator {

	private final String _name;
	protected ValidatorInputStream _input;
	protected long _startLocation;
	protected String _currentSymbol;
	protected String _currentSequence;
	private String _currentSubSequence;

	public Validator(String name) {
		_name = name;
		_startLocation = 0;
		_currentSymbol = "";
		_currentSequence = "";
		_currentSubSequence = "";
	}

	public String getName() {
		return _name;
	}
	
	public abstract String getExtension();

	public void setStream(ValidatorInputStream input) {
		_input = input;
	}

	public ParseResult tryParse() {
		try {
			return tryParseBody();
		} catch (IOException e) {
			e.printStackTrace();
			return no();
		}
	}

	protected abstract ParseResult tryParseBody() throws IOException;

	public abstract ParseResult findNextFooter() throws IOException;
	
	protected void markStart() {
		_startLocation = _input.lastLocation();
	}

	protected void addSubSequence(String name) {
	  _currentSubSequence += name;
	}

	protected void clearSubSequence() {
	  _currentSubSequence = "";
	}
	
	protected void mergeSubSequence() {
	  _currentSequence += " " + _currentSubSequence;
	  _currentSubSequence = "";
	}

	protected ParseResult yes() {
		return new ParseResult(true, _input.lastLocation(), _input.lastRead(), _currentSymbol, _currentSequence);
	}

	protected ParseResult no() {
		return new ParseResult(false, _input.lastLocation(), _input.lastRead(), _currentSymbol, _currentSequence);
	}
	
	protected boolean noMatch() {
		try {
			_input.skip(_startLocation - _input.lastLocation());
		} catch (IOException e) {
			e.printStackTrace();
		}
		return false;
	}

}
