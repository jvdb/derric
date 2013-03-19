package org.derric_lang.validator.interpreter.symbol;

import java.io.IOException;

import org.derric_lang.validator.interpreter.Interpreter;

public abstract class Symbol {
	
	public abstract boolean parse(Interpreter in) throws IOException;

}
