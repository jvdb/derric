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

import org.junit.Assert;
import org.junit.Test;

public class TestByteOrder {

  @Test
  public void testBigEndianOnEvenSizeArray() {
    byte[] test = { 1, 2, 3, 4 };
    byte[] ref = test.clone();
    ByteOrder.BIG_ENDIAN.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testBigEndianOnUnevenSizeArray() {
    byte[] test = { 1, 2, 3, 4, 5 };
    byte[] ref = test.clone();
    ByteOrder.BIG_ENDIAN.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testBigEndianOnEmptyArray() {
    byte[] test = {};
    byte[] ref = test.clone();
    ByteOrder.BIG_ENDIAN.apply(test);
    Assert.assertArrayEquals(ref, test);
  }

  @Test
  public void testLittleEndianOnEvenSizeArray() {
    byte[] test = { 1, 2, 3, 4 };
    byte[] ref = { 4, 3, 2, 1 };
    ByteOrder.LITTLE_ENDIAN.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testLittleEndianOnUnevenSizeArray() {
    byte[] test = { 1, 2, 3, 4, 5 };
    byte[] ref = { 5, 4, 3, 2, 1 };
    ByteOrder.LITTLE_ENDIAN.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testLittleEndianOnEmptyArray() {
    byte[] test = {};
    byte[] ref = test.clone();
    ByteOrder.BIG_ENDIAN.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
}
