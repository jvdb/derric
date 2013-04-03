module lang::derric::ExecuteValidator

import lang::derric::FileFormat;
import lang::derric::Validator;

@javaClass{org.derric_lang.validator.ExecuteInterpreter}
public java tuple[bool, list[tuple[str, loc, loc, loc, list[tuple[str, loc, loc]]]]] executeValidator(str format, list[Symbol] sequence, list[Structure] structs, list[Global] globals, loc inputPath);
