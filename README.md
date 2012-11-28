# Derric, a DSL for Digital Forensics #

Derric is a domain-specific language created to simplify and speed up the development of file format validators, which are software components used to identify the type of a file or data structure presented to it. These type of components are typically used in automated digital forensics tools, such as file carvers, that use validators to identify files based on their contents in order to recover them.

Three example descriptions are provided in the `/formats` directory of the repository, describing at a base level of detail the file formats of JPEG, PNG and GIF files.

## Installing##

The Derric compiler was written in [Rascal](http://www.rascal-mpl.org/), a
metaprogramming language developed as a research project at the [CWI](http://www.cwi.nl/). In order to run Derric, you need to have Rascal installed. The Rascal site has [a description](http://www.rascal-mpl.org/Rascal/EclipseUpdate) of how to install Rascal as part of Eclipse. This project can be loaded into an Eclipse installation that has the Rascal plug-in enabled.

## Running the compiler ##

The compiler's entrypoint is located in the module lang::derric::testparse. To run it, open a Rascal console (right-click in any Rascal file's edit window and select "Launch Console") and enter:

    import lang::derric::testparse;

This will take a while depending on the speed of your machine (parsers are generated) and will return with "OK". Next, to run the compiler on the provided JPEG description, enter:

    generate(|project://derric/formats/jpeg.derric|);

To run the compiler on all three example descriptions (JPEG, PNG and GIF), enter:

    generateAll();

This will show some output and terminate. The result will be a bunch of generated files:

`/src/org/lang_derric/validator/generated` will contain Java source files containing code that attempts to validate whether a stream passed to it is of the type it validates (e.g. JPEGValidator attempts to determine whether a file provided is JPEG or not).

`/src/org/lang_derric/validator/generated/ValidatorFactory.java` contains the source of a factory that, based on a provided file extension, matches a validator to that extension and returns the associated validator (e.g., if you call ValidatorFactory.create("gif") it will return an instance of GIFValidator. At least, if you've generated the GIFValidator).

`/src/org/lang_derric/validator/generated` also contains the optimized versions of the input descriptions in Derric, for debug purposes.

A small set of unit and integration tests is provided. After running generateAll() in the Rascal console, refresh the project and run the tests (right-click on the test directory and select "Run As" and then select "JUnit Test"). If all running tests succeed then the installation works.

## Language reference ##

A Derric description are plaintext files. A description consists of four parts: a format definition, a set of defaults, a sequence definition and a set of structures. The following sections describe these parts in detail.

### Format ###

A Derric description always starts with the keyword `format` followed by the name of the format it describes. This name is only used as a description, so its value is unrelated to how the actual generated code will function. It is used to identify a description. Typically, the name used after format is also the name of the file.

Next is the keyword `extension` that is followed by a space separated list of extensions. These extensions are used to allow the generated code to specify the file extensions used by the file format it describes. One thing about the order in which extensions are specified is important: the first extension defined will be used by the generated code to suggest as extension.

    format jpeg
    extension jpg jpeg jfif

In the example above, the name of the format is `jpeg` and files of that type should have one of the extensions `jpg`, `jpeg` or `jfif`. Of the specified extensions, `jpg` is considered the default.

### Defaults ###

Following the format definition is an optional set of defaults that apply to all fields describes in the description. This includes the default size of fields with `size` (must be a numerical expression) and `unit` (either `bit` or `byte`), encoding with `endian` (either `little` or `big`), datatype with `type` (either `integer` or `string`), string encoding with `strings` (currently only `ascii` is supported) and integer value encoding with `sign` (`true` or `false` for signed or unsigned integers respectively).

    size 1
    unit byte
    sign false
    type integer
    endian big
    strings ascii

The example above shows the default values for all possible defaults. Only if (most of) the description uses different encoding than shown in the defaults above, they should de defined in the description.

### Sequence ###

Next is the sequence, which always starts with the keyword `sequence`. Following is a regular expression describing at data structure level, the order in which structures appear in the format described. The names in the sequence must all be defined in the following structures section. Supported constructs are not (`!`), optional (`?`), zeroOrMore (`*`), anyOf (`( ... )`) and fixedOrder (`[ ... ]`).

    (Header87a Header89a)
    LogicalScreenDesc
    (
      [GraphicControlExtension? TableBasedImage CompressedDataBlock*]
      [GraphicControlExtension? PlainTextExtension DataBlock*]
      [ApplicationExtension DataBlock*]
      [CommentExtension DataBlock*]
    )
    ZeroBlock
    (
      [GraphicControlExtension? TableBasedImage CompressedDataBlock* ZeroBlock]
      [GraphicControlExtension? PlainTextExtension DataBlock* ZeroBlock]
      [ApplicationExtension DataBlock* ZeroBlock]
      [CommentExtension DataBlock* ZeroBlock]
    )*
    Trailer

In the example above, a file of the described format always starts with either the `Header87a` or `Header89a` structure. After that, there is always a `LogicalScreenDesc`. Next is one of the four fixedOrders, the first consists of an optional `GraphicControlExtension` (note the `?`), followed by a `TableBasedImage` and zero or more `CompressedDataBlock` structures. After that there is always a `ZeroBlock`. Following that is again any of four specified fixedOrders, but this time zero or more of them (note the `*` following the enclosing `( ... )`). Finally there is always a `Trailer`.

### Structures ###

All of the structures defined in the sequence must be described in the structures section, which always starts with the `structures` keyword. Each structure starts with its name, followed by curley braces (`{ ... }`) that enclose its individual fields. The order in which fields appear in a structure, corresponds to the order in which the data is actually laid out in files of the format it describes. Fields have a name and optionally a description of their value.

#### Constants and Expressions ####

    structures
    Signature {
      marker: 137, 80, 78, 71, 13, 10, 26, 10;
    }

The example above shows a basic structure with a single field called `marker`. Multiple values may be defined in a single field by using a comma as delimeter. The following example is a structure called `DemoStruct` and has fourteen fields, features used are discussed inline.

    structures
    DemoStruct {
      fixedNumbers: 12, 0xFF, 0o23, 0b0101;
      fixedString: "a string";

The first field, `fixedNumbers`, consists of four values, all encoded differently: decimal (`12`), hexadecimal (`0xFF`), octal (`0o23`) and binary (`0b0101`). Note that the notation for octal is different from that in most C-like languages (to make it more consistent with the notations for hexadecimal and binary). The next field, `fixedString` contains a constant string.

      constantExpression: (((5+7)-(2*2))/2)^3;
      localReference: constantExpression;
      globalReference: otherStructure.someField;
      referencingExpression: localReference+1;

Next is the field `constantExpression`, which shows an expression as a value description. `localReference` is defined to have the same value as the preceding `constantExpression` field. `globalReference` is defined to have the same value as a field in another structure. This requires that the structure containing the referenced field (in this case `otherStructure`) precedes the referencing structure in the sequence. `referencingExpression` shows that references can be used in expressions.

      range: 5..125;
      not: !17;
      or: 1|2|4|6;
      combinations: 1..7|9;

The `range` field shows the operator to define a value within a specific range. Not that the ranges are inclusive (e.g. when the range is `5..125` the values `5` and `125` are considered allowed values). The `not` and `or` fields show what their name suggests. The `combinations` field shows that these operators can be combined into a single field description.

      empty;

The field `empty` shows that a field does not need to have a value defined if it is unknown and unconstrained.

      builtIns: offset(constantExpression)-lengthOf(empty);

There are currently two built-in functions that can be used in descriptions and expressions: `lengthOf(fieldName)` and `offset(fieldName)`. The former returns the size and the latter the offset of the referenced field, calculated from the start of the structure. In this case the value specification resolves to 11: the offset of `constantExpression` is 12 (because the preceding fields have a size of 12 bytes: 4 bytes in `fixedNumbers` and 8 bytes in `fixedString`) and the length of the `empty` field is 1 byte. All this assumes that no default encoding values are overridden.

      localEncodings: 5 size 4 endian little;
      sizeExpression: size constantExpression+lengthOf(empty);
    }

The encodings defined near the top of a Derric description can be overridden at the field level. Examples of this are shown in the fields `localEncodings` and `sizeExpression`. The latter demonstrates that the value of `size` can be any expression.

Additional examples of the features discussed in this section can be found in the file `/formats/test/test.derric` in the distribution.

#### Templates and Overrides ####

Derric supports a kind of structure inheritance called templates. This way, similar parts of different structures can be defined in a single location to prevent redundancy and associated maintenance issues. Inherited fields' descriptions can be overridden by defining a new description or by defining multiple fields to replace it. Following is an example of a template called `DemoTemplate` and another structure called `TemplateUser` that uses it and overrides parts of it.

    structures
    DemoTemplate {
      marker: size 4;
      length: lengthOf(data) size 2;
      data: size length;
    }
    
    TemplateUser = DemoTemplate {
      marker: "mrk";
      data {
        key: 12;
        value: size 20;
      }
    }

The inheritance takes place where a structures is named: `TemplateUser = DemoTemplate` states that `TemplateUser` uses `DemoTemplate` as a template and as a result, gets a copy of all of `DemoTemplate`'s fields. Next, it overrides the description of the field `marker` by defining the value as the string `"mrk"`, effectively also changing the size from 4 to 3 bytes. The field `length` is copied but not overridden, so it appears in `TemplateUser` the same way it does in `DemoTemplate`. Finally, the field `data` is overridden by two new fields: `key` and `value`. This construct allows template structures to be general and user structures to be specific.

An additional and extensive example of the features discussed in this section can be found in the file `/formats/test/test2.derric` in the distribution.

#### Content analysis ####

Some values are impractical to describe using a declarative language such as Derric. Examples are compressed data and hash values. Also, since the way these types of fields' data encoding is implemented is relatively stable, it makes sense to use a callback mechanism so existing libraries can be used to validate the values of such fields.

    structures
    Chunk {
      length: lengthOf(chunkdata) size 4;
      chunktype: size 4;
      chunkdata: size length;
      crc: checksum(algorithm="crc32-ieee",
                    init="allone",
                    start="lsb",
                    end="invert",
                    store="msbfirst",
                    fields=chunktype+chunkdata)
           size 4;
    }

In the `Chunk` structure in the example above, the `crc` field uses the callback mechanism to calculate a crc32 hash value for its specification. All callbacks have a name followed by parentheses. Between the parentheses, optional arguments may be provided in the form `name=value`. Besides strings and numeric values, field references (both local and global) are allowed. Note that the `+` operator in this context is used to specify a list of references. Any other expression is not allowed.

## Additional notes ##

This project is a work in progress. A lot of cleanup and additional language features are planned. Especially the Java runtime library the generated code depends on (located in `/src/org/derric_lang/validator`) is meant purely to allow the code to run independently but is not optimized for speed, scale or clarity. In order to integrate the generated code with a real application, it is recommended to develop a runtime library that takes the application's goals and environment into account.

The callback mechanism is currently still under development and therefore not fully documented, since major changes are still expected.

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
