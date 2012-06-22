@license{
   Copyright 2011-2012 Netherlands Forensic Institute and
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
}

module lang::derric::testfeature

import lang::derric::testparse;

loc testPath = |project://derric/formats/test.derric|;
loc testPath2 = |project://derric/formats/test2.derric|;
loc testPath3 = |project://derric/formats/test3.derric|;

public void parseTestAll() {
	parseTest();
	parseTest2();
	parseTest3();
}

public void parseTest() {
	generate(testPath);
}

public void parseTest2() {
	generate(testPath2);
}

public void parseTest3() {
	generate(testPath3);
}