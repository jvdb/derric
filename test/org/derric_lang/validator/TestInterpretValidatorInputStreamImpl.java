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
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import junit.framework.Assert;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;

public class TestInterpretValidatorInputStreamImpl {

	private static String _path;
	private static ValidatorInputStreamImpl _input;
	private static byte[] _data;
	
	@BeforeClass public static void beforeClass() throws IOException {
		File data = File.createTempFile("simpleValidatorInputStreamInterpretTest", null);
		data.deleteOnExit();
		_path = data.getPath();
		FileOutputStream output = new FileOutputStream(data);
		// In bits: 01010101, 11010110, 10110100, 00011101
		// In signed decimal bytes: 85, -42, -76, 29
		// In unsigned decimal bytes: 85, 214, 180, 29
		// In hexadecimal bytes: 0x55, 0xD6, 0xB4, 0x1D
		_data = new byte[] { 85, -42, -76, 29 };
		output.write(_data);
		output.close();
	}
	
	@Before public void beforeTest() throws FileNotFoundException {
		_input = new ValidatorInputStreamImpl(new InMemoryInputStream(_path), null);
	}
	
	@Test public void basicByteReadAsByte() throws IOException {
		Assert.assertEquals(_data[0], (byte)_input.unsigned().readInteger(8));
		Assert.assertEquals(_data[1], (byte)_input.unsigned().readInteger(8));
		Assert.assertEquals(_data[2], (byte)_input.unsigned().readInteger(8));
		Assert.assertEquals(_data[3], (byte)_input.unsigned().readInteger(8));
	}

	@Test public void readSignedBytes() throws IOException {
		Assert.assertEquals(_data[0], (byte)_input.signed().readInteger(8));
    Assert.assertEquals(_data[1], (byte)_input.signed().readInteger(8));
    Assert.assertEquals(_data[2], (byte)_input.signed().readInteger(8));
    Assert.assertEquals(_data[3], (byte)_input.signed().readInteger(8));
	}
	
	@Test public void readUnsignedByteIntegersWithinBytes() throws IOException {
		Assert.assertEquals(0, _input.unsigned().readInteger(1));
		Assert.assertEquals(85, _input.unsigned().readInteger(7));
		Assert.assertEquals(1, _input.unsigned().readInteger(1));
		Assert.assertEquals(86, _input.unsigned().readInteger(7));
		Assert.assertEquals(5, _input.unsigned().readInteger(3));
		Assert.assertEquals(5, _input.unsigned().readInteger(3));
		Assert.assertEquals(0, _input.unsigned().readInteger(2));
		Assert.assertEquals(1, _input.unsigned().readInteger(4));
		Assert.assertEquals(13, _input.unsigned().readInteger(4));
	}

	@Test public void readSignedByteIntegersWithinBytes() throws IOException {
		Assert.assertEquals(0, _input.signed().readInteger(1));
		Assert.assertEquals(-43, _input.signed().readInteger(7));
		Assert.assertEquals(-1, _input.signed().readInteger(1));
		Assert.assertEquals(-42, _input.signed().readInteger(7));
		Assert.assertEquals(-3, _input.signed().readInteger(3));
		Assert.assertEquals(-3, _input.signed().readInteger(3));
		Assert.assertEquals(0, _input.signed().readInteger(2));
		Assert.assertEquals(1, _input.signed().readInteger(4));
		Assert.assertEquals(-3, _input.signed().readInteger(4));
	}

	@Ignore("Enable when runtime library supports non-byte aligned multi-byte values.")
	@Test public void readUnsignedByteIntegersAcrossBytes() throws IOException {
		Assert.assertEquals(2, _input.unsigned().readInteger(3));
		Assert.assertEquals(87, _input.unsigned().readInteger(7));
		Assert.assertEquals(45, _input.unsigned().readInteger(7));
		Assert.assertEquals(26, _input.unsigned().readInteger(6));
		Assert.assertEquals(1, _input.unsigned().readInteger(5));
		Assert.assertEquals(13, _input.unsigned().readInteger(4));
	}

  @Ignore("Enable when runtime library supports non-byte aligned multi-byte values.")
	@Test public void readSignedByteIntegersAcrossBytes() throws IOException {
		Assert.assertEquals(10, _input.signed().readInteger(5));
		Assert.assertEquals(-5, _input.signed().readInteger(4));
		Assert.assertEquals(-11, _input.signed().readInteger(5));
		Assert.assertEquals(-42, _input.signed().readInteger(7));
		Assert.assertEquals(-32, _input.signed().readInteger(6));
		Assert.assertEquals(-3, _input.signed().readInteger(5));
	}
	
	@Test public void readSignedShortIntegers() throws IOException {
		Assert.assertEquals(21974, _input.signed().readInteger(16));
		Assert.assertEquals(-19427, _input.signed().readInteger(16));
	}
	
  @Ignore("Enable when runtime library supports non-byte aligned multi-byte values.")
	@Test public void readUnsignedIntegersAcrossBytes() throws IOException {
		Assert.assertEquals(5493, _input.unsigned().readInteger(14));
		Assert.assertEquals(177181, _input.unsigned().readInteger(18));
	}

  @Ignore("Enable when runtime library supports non-byte aligned multi-byte values.")
	@Test public void readSignedShortIntegersAcrossBytes() throws IOException {
		Assert.assertEquals(10, _input.signed().readInteger(5));
		Assert.assertEquals(-2214, _input.signed().readInteger(13));
		Assert.assertEquals(-381, _input.signed().readInteger(11));
		Assert.assertEquals(-3, _input.signed().readInteger(3));
	}

	@Test public void readSignedInteger() throws IOException {
		Assert.assertEquals(1440134173, _input.signed().readInteger(32));
	}
}
