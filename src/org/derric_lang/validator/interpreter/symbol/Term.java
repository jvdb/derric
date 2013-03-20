package org.derric_lang.validator.interpreter.symbol;

import java.io.IOException;

import org.derric_lang.validator.interpreter.Interpreter;

public class Term extends Symbol {
    
    private final String _name;
	
	public Term(String name) {
	    _name = name;
	}

    @Override
    public boolean parse(Interpreter in) throws IOException {
        if (allowEOFSet() && in.getInput().atEOF()) {
            return _allowEOF;
        }
    	return in.parseStructure(_name);
    }
}
