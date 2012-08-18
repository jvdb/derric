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

import java.io.EOFException;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import junit.framework.Assert;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestReadValidatorInputStreamImpl {
	
	public static final int SIZE = 1024*1024;

	private static String _path;
	private static ValidatorInputStreamImpl _input;
	
	@BeforeClass public static void beforeClass() throws IOException {
		File data = File.createTempFile("simpleValidatorInputStreamReadTest", null);
		data.deleteOnExit();
		_path = data.getPath();
		FileOutputStream output = new FileOutputStream(data);
		for (int i = 0; i < SIZE; i++) {
			output.write(i % 256);
		}
		output.close();
	}
	
	@Before public void beforeTest() throws FileNotFoundException {
		_input = new ValidatorInputStreamImpl(new InMemoryInputStream(_path), null);
	}
	
	@Test public void readBytes() throws IOException {
		for (int i = 0; i < SIZE; i++) {
			Assert.assertEquals(i % 256, _input.readInteger(8));
		}
	}
	
	@Test public void seekAndReadBytes() throws IOException {
		final int seekSize = 97;
		for (int r = 0; r+seekSize+1 < SIZE; r += seekSize+1) {
			Assert.assertEquals(r % 256, _input.readInteger(8));
			_input.skipBits(8*seekSize);
		}
	}
	
	@Test public void lastLocation() throws IOException {
		final int seekSize = 197;
		for (int r = 0; r+seekSize+1 < SIZE; r += seekSize+1) {
			Assert.assertEquals(r, _input.lastLocation());
			_input.readInteger(8);
			Assert.assertEquals(r+1, _input.lastLocation());
			_input.skipBits(8*seekSize);
			Assert.assertEquals(r+1+seekSize, _input.lastLocation());
		}
	}

	@Test public void lastRead() throws IOException {
		final int seekSize = 197;
		for (int r = 0; r+seekSize+1 < SIZE; r += seekSize+1) {
			_input.readInteger(8);
			Assert.assertEquals(r, _input.lastRead());
			_input.skipBits(8*seekSize);
			Assert.assertEquals(r, _input.lastRead());
		}
	}
	
	@Test public void markResetWithRead() throws IOException {
		int markr = 0;
		boolean b = false;
		for (int r = 0; r < SIZE; r++) {
			Assert.assertEquals(r % 256, _input.readInteger(8));
			if (r == (SIZE/4)) {
				_input.mark();
				markr = r;
			}
			if (r == (SIZE/2)) {
				if (b) break;
				_input.reset();
				r = markr;
				b = true;
			}
		}
	}

	@Test public void markResetWithSeek() throws IOException {
		final int seekSize = 97;
		int markr = 0;
		boolean b = false;
		for (int r = 0; r < SIZE; r += seekSize+1) {
			Assert.assertEquals(r % 256, _input.readInteger(8));
			_input.skipBits(8*seekSize);
			if (r >= (SIZE/4)) {
				_input.mark();
				markr = r;
			}
			if (r >= (SIZE/2)) {
				if (b) break;
				_input.reset();
				r = markr;
				b = true;
			}
		}
	}

	@Test public void markResetLastLocation() throws IOException {
		final int seekSize = 97;
		int markr = 0;
		boolean b = false;
		for (int r = 0; r < SIZE; r += seekSize+1) {
			Assert.assertEquals(r, _input.lastLocation());
			_input.readInteger(8);
			Assert.assertEquals(r+1, _input.lastLocation());
			_input.skipBits(8*seekSize);
			Assert.assertEquals(r+seekSize+1, _input.lastLocation());
			if (r >= (SIZE/4)) {
				_input.mark();
				markr = r;
			}
			if (r >= (SIZE/2)) {
				if (b) break;
				_input.reset();
				r = markr;
				b = true;
			}
		}
	}

	@Test public void markResetLastRead() throws IOException {
		final int seekSize = 97;
		int markr = 0;
		boolean b = false;
		for (int r = 0; r < SIZE; r += seekSize+1) {
			_input.readInteger(8);
			Assert.assertEquals(r, _input.lastRead());
			_input.skipBits(8*seekSize);
			Assert.assertEquals(r, _input.lastRead());
			if (r >= (SIZE/4)) {
				_input.mark();
				markr = r;
			}
			if (r >= (SIZE/2)) {
				if (b) break;
				_input.reset();
				r = markr;
				b = true;
			}
		}
	}
	
	@Test(expected=EOFException.class) public void readPastEnd() throws IOException {
    Assert.assertEquals(false, _input.atEOF());
		readBytes();
    Assert.assertEquals(true, _input.atEOF());
		_input.readInteger(8);
	}

	@Test(expected=EOFException.class) public void seekPastEnd() throws IOException {
		readBytes();
		Assert.assertEquals(false, _input.skipBits(8*102));
	}
	
	@Test public void partialSeekPastEnd() throws IOException {
		final int delta = 50;
		_input.skipBits(8*SIZE - delta);
		Assert.assertEquals(false, _input.skipBits(8*delta*3));
	}

	@Test(expected=EOFException.class) public void readAfterSeekPastEnd() throws IOException {
    Assert.assertEquals(false, _input.atEOF());
		Assert.assertEquals(false, _input.skipBits(8*SIZE * 2));
    Assert.assertEquals(true, _input.atEOF());
		_input.readInteger(8);
	}
}
