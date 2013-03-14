package org.derric_lang.validator.interpreter.symbol;

import org.derric_lang.validator.interpreter.Interpreter;

public class Iter extends Symbol {
	
	private final Symbol _symbol;
	
	public Iter(Symbol symbol) {
	    _symbol = symbol;
	}

    @Override
    public boolean parse(Interpreter in) {
        while(_symbol.parse(in));
        return true;
    }

}
