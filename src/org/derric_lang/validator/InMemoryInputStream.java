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

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;

public class InMemoryInputStream extends InputStream {

	private byte[] _contents;
	private int _offset;
	private boolean _marked;
	private int _markedOffset;
	private final int _size;

	public InMemoryInputStream(String path) {
		this(new File(path));
	}
	
	public InMemoryInputStream(URI path) {
		this(new File(path));
	}
	
	private InMemoryInputStream(File file) {
		try {
			long size = file.length();
			if (size > Integer.MAX_VALUE) throw new RuntimeException("Files larger than 2GB are not supported.");
			_size = (int) size;
			_contents = new byte[_size];
			FileInputStream input = new FileInputStream(file);
			input.read(_contents);
			input.close();
			_offset = 0;
			_marked = false;
		} catch (IOException e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	
	}
	
	@Override
	public int available() {
	  return _size - _offset;
	}

	@Override
	public void mark(int readLimit) {
		_marked = true;
		_markedOffset = _offset;
	}

	@Override
	public void reset() {
		if (!_marked) throw new RuntimeException("Stream was not marked.");
		_marked = false;
		_offset = _markedOffset;
	}

	@Override
	public boolean markSupported() {
		return true;
	}

	@Override
	public int read() throws IOException {
		if (_offset >= _size) return -1;
		return _contents[_offset++] & 0xFF;
	}

	@Override
	public long skip(long size) {
		if (size >= 0) {
			if (size <= (_size - _offset)) {
				_offset += (int) size;
				return size;
			} else {
				long ret = _size - _offset;
				_offset = _size;
				return ret;
			}
		} else {
			if (Math.abs(size) <= _offset) {
				_offset -= (int) Math.abs(size);
				return size;
			} else {
				long ret = (long) -_offset;
				_offset = 0;
				return ret;
			}
		}
	}

}
