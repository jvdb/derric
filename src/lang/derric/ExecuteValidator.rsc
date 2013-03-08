module lang::derric::ExecuteValidator

import lang::derric::FileFormat;
import lang::derric::Validator;

//data Result = result(bool succeeded, int lastLocation, int lastRead, str currentSymbol, str currentSequence);

@javaClass{org.derric_lang.validator.ExecuteInterpreter}
public java bool executeValidator(str format, list[Symbol] sequence, list[Structure] structs, loc inputPath);
