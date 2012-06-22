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

public class TestBitOrder {
  
  @Test
  public void testMSBFirstOnEmptyArray() {
    byte[] test = {};
    byte[] ref = test.clone();
    BitOrder.MSB_FIRST.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testMSBFirstOnArray() {
    byte[] test = { 1, 2, 3, 4, 5 };
    byte[] ref = test.clone();
    BitOrder.MSB_FIRST.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testMSBFirstOnSingleValues() {
    byte[] test = { 1, 2, 3, 4, 5 };
    byte[] ref = test.clone();
    for (int i = 0; i < test.length; i++) {
      Assert.assertEquals(ref[i], BitOrder.MSB_FIRST.apply(test[i]));
    }
  }
  
  @Test
  public void testLSBFirstOnEmptyArray() {
    byte[] test = {};
    byte[] ref = test.clone();
    BitOrder.LSB_FIRST.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testLSBFirstOnArray() {
    byte[] test = { 1, 2, 3, 4, 5 };
    byte[] ref = { (byte) 128, 64, (byte) 192, 32, (byte) 160 };
    BitOrder.LSB_FIRST.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testLSBFirstOnArrayWithMirroredBitPatterns() {
    byte[] test = { (byte) 255, (byte) 129, (byte) 195, (byte) 231, (byte) 255, 0, 24, 60, 126, (byte) 165, 90 };
    byte[] ref = test.clone();
    BitOrder.LSB_FIRST.apply(test);
    Assert.assertArrayEquals(ref, test);
  }
  
  @Test
  public void testLSBFirstOnSingleMirroredValues() {
    byte[] test = { (byte) 255, (byte) 129, (byte) 195, (byte) 231, (byte) 255, 0, 24, 60, 126, (byte) 165, 90 };
    for (int i = 0; i < test.length; i++) {
      Assert.assertEquals(test[i], BitOrder.LSB_FIRST.apply(test[i]));
    }
  }
  
  @Test
  public void testLSBFirstOnSingleValues() {
    byte[] test = { 1, 2, 3, 4, 5 };
    byte[] ref = { (byte) 128, 64, (byte) 192, 32, (byte) 160 };
    for (int i = 0; i < test.length; i++) {
      Assert.assertEquals(ref[i], BitOrder.LSB_FIRST.apply(test[i]));
    }
  }
}
