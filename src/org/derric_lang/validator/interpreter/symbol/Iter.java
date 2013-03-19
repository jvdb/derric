package org.derric_lang.validator.interpreter.symbol;

import java.io.IOException;

import org.derric_lang.validator.interpreter.Interpreter;

public class Iter extends Symbol {
	
	private final Symbol _symbol;
	
	public Iter(Symbol symbol) {
	    _symbol = symbol;
	}

    @Override
    public boolean parse(Interpreter in) throws IOException {
        while(_symbol.parse(in));
        return true;
    }

}
