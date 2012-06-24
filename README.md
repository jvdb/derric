# Derric, a DSL for Digital Forensics #

Derric is a domain-specific language created to simplify and speed up the development of file format validators, which are software components used to identify the type of a file or data structure presented to it. These type of components are typically used in automated digital forensics tools, such as file carvers, that use validators to identify files based on their contents in order to recover them.

Three example descriptions are provided in the `/formats` directory of the repository, describing at a base level of detail the file formats of JPEG, PNG and GIF files.

## Installing ##

The Derric compiler was written in [Rascal](http://www.rascal-mpl.org/), a
metaprogramming language developed as a research project at the [CWI](http://www.cwi.nl/). In order to run Derric, you need to have Rascal installed. The Rascal site has [a description](http://www.rascal-mpl.org/Rascal/EclipseUpdate) of how to install Rascal as part of Eclipse. This project can be loaded into an Eclipse installation that has the Rascal plug-in enabled.

## Developing ##

The compiler's entrypoint is located in the module lang::derric::testparse. To run it, open a Rascal console (right-click in any Rascal file's edit window and select "Launch Console") and enter:

    import lang::derric::testparse;

This will take a while depending on the speed of your machine (parsers are generated) and will return with "OK". Next, to run the compiler on the provided JPEG description, enter:

    generate(|project://derric/formats/jpeg.derric|);

To run the compiler on all three example descriptions (JPEG, PNG and GIF), enter:

    generateAll();

This will show some output and terminate. The result will be a bunch of generated files:

`/src/org/lang_derric/validator/generated` will contain Java source files containing code that attempts to validate whether a stream passed to it is of the type it validates (e.g. JPEGValidator attempts to determine whether a file provided is JPEG or not).

`/src/org/lang_derric/validator/generated/ValidatorFactory.java` contains the source of a factory that, based on a provided file extension, matches a validator to that extension and returns the associated validator (e.g., if you call ValidatorFactory.create("gif") it will return an instance of GIFValidator. At least, if you've generated the GIFValidator).

`/formats/out/` contains the optimized versions of the input descriptions in Derric, for debug purposes.

A small set of unit and integration tests is provided. After running generateAll() in the Rascal console, refresh the project and run the tests (right-click on the test directory and select "Run As" and then select "JUnit Test"). If all running tests succeed then the installation works.

## Additional notes ##

This project is a work in progress. A lot of cleanup and additional language features are planned. Especially the Java runtime library the generated code depends on (located in `/src/org/derric_lang/validator`) is meant purely to allow the code to run independently but is not optimized for speed, scale or clarity. In order to integrate the generated code with a real application, it is recommended to develop a runtime library that takes the application's goals and environment into account.

A good example of how to use the generated code in combination with the runtime library is shown in the code to the integration tests located in the file `/src/org/derric_lang/validator/TestGeneratedValidators.java`. The method testGeneratedValidator() shows how the generated code can be used in practice.

### Testdata ###

The `/testdata` folder contains a set of files used by an automated integration test in `/test/org/derric_lang/validator/TestGeneratedValidators.java`. This test class builds a list of all files in the `/testdata` folder, then uses the factory in `src/org/derric_lang/validator/generated/ValidatorFactory.java` to find a matching validator for each file and run the selected validator on the file.

The following files are in the `/testdata` folder:

1. JPEG_example_JPG_RIP_100.jpg
2. 280px-PNG_transparency_demonstration_1.png
3. 200px-Rotating_earth_%28large%29.gif
4. canon-ixus.jpg
5. kodak-dc210.jpg
6. sanyo-vpcg250.jpg
7. sony-d700.jpg
8. GEDRP3V2.JPG
9. PARROTS.JPG

Files 1, 2 and 3 are taken from Wikipedia, from the pages on [JPEG](http://en.wikipedia.org/wiki/JPEG), [PNG](http://en.wikipedia.org/wiki/Portable_Network_Graphics) and [GIF](http://en.wikipedia.org/wiki/Graphics_Interchange_Format) respectively and selected as typical examples. Files 4, 5, 6 and 7 are taken from [Exif.org's samples](http://www.exif.org/samples.html) and selected because they contain Exif data in different versions and metadata combinations. Files 8 and 9 are taken from [Fileformat.info's JFIF samples](http://www.fileformat.info/format/jpeg/sample/index.htm) and selected as additional examples of JPEG files containing JFIF metadata.

## License ##
Copyright 2011-2012 Netherlands Forensic Institute and Centrum Wiskunde & Informatica

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
