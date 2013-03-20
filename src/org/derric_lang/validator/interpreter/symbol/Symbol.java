package org.derric_lang.validator.interpreter.symbol;

import java.io.IOException;

import org.derric_lang.validator.interpreter.Interpreter;

public abstract class Symbol {
    
    protected boolean _allowEOF = false;
    protected boolean _allowEOFSet = false;
    
    public void setAllowEOF(boolean allowEOF) {
        _allowEOF = allowEOF;
        _allowEOFSet = true;
    }
    
    protected boolean allowEOFSet() {
        return _allowEOFSet;
    }
    
    public abstract boolean parse(Interpreter in) throws IOException;

}
