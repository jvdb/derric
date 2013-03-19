package org.derric_lang.validator.interpreter.symbol;

import java.io.IOException;

import org.derric_lang.validator.interpreter.Interpreter;

public class Optional extends Symbol {
    
    private final Symbol _symbol;
	
	public Optional(Symbol symbol) {
	    _symbol = symbol;
	}

    @Override
    public boolean parse(Interpreter in) throws IOException {
        _symbol.parse(in);
        return true;
    }

}
