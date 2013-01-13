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
import java.util.ArrayList;
import java.util.Collection;

import org.derric_lang.validator.generated.ValidatorFactory;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

@RunWith(Parameterized.class)
public class TestGeneratedValidators {

	public final static String TEST_DIRECTORY = "testdata";
	
	private String _name;
	
	@Parameters
	public static Collection<Object[]> getArgument() {
		File testDir = new File(TEST_DIRECTORY);
		if (!testDir.isDirectory()) throw new RuntimeException(TEST_DIRECTORY + " must be a directory.");
		return getFileNames(testDir);
	}
	
	private static Collection<Object[]> getFileNames(File node) {
		ArrayList<Object[]> names = new ArrayList<Object[]>();
		if (node.getName().startsWith(".")) return names;
		if (node.isDirectory()) {
			for (File f : node.listFiles()) {
				names.addAll(getFileNames(f));
			}
		} else {
			names.add(new Object[] { node.getPath() });
		}
		return names;
	}
	
	public TestGeneratedValidators(String name) {
		_name = name;
	}
	
	private String getExtension(String path) {
		return path.substring(path.lastIndexOf(".") + 1).toLowerCase();
	}

	@Test
	public void testGeneratedValidator() {
		Validator validator = ValidatorFactory.create(getExtension(_name));
		ValidatorInputStream stream = ValidatorInputStreamFactory.create(_name);
		validator.setStream(stream);
		ParseResult result = validator.tryParse();
		Assert.assertTrue("Parsing failed. " + validator.getClass() + " on " + _name + ". Last read: " + result.getLastRead() + "; Last location: " + result.getLastLocation() + "; Last symbol: " + result.getSymbol() + "; Sequence: " + result.getSequence(), result.isSuccess());
	}

}
