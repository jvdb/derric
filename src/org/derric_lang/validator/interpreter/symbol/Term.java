package org.derric_lang.validator.interpreter.symbol;

import org.derric_lang.validator.interpreter.Interpreter;

public class Term extends Symbol {
    
    private final String _name;
	
	public Term(String name) {
	    _name = name;
	}

    @Override
    public boolean parse(Interpreter in) {
        return in.getStructure(_name).parse(in);
    }

}
