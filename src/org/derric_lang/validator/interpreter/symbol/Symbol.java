package org.derric_lang.validator.interpreter.symbol;

import java.io.IOException;

import org.derric_lang.validator.interpreter.Interpreter;
import org.eclipse.imp.pdb.facts.ISourceLocation;

public abstract class Symbol {
    
    protected boolean _allowEOF = false;
    protected boolean _allowEOFSet = false;
    protected ISourceLocation _location;
    
    public void setAllowEOF(boolean allowEOF) {
        _allowEOF = allowEOF;
        _allowEOFSet = true;
    }
    
    protected boolean allowEOFSet() {
        return _allowEOFSet;
    }
    
    public void setLocation(ISourceLocation location) {
    	_location = location;
    }
    
    public abstract boolean parse(Interpreter in) throws IOException;
    
    public abstract boolean isEmpty();
    
}
