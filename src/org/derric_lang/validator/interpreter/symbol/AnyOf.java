package org.derric_lang.validator.interpreter.symbol;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import org.derric_lang.validator.interpreter.Interpreter;

public class AnyOf extends Symbol {
	
	private final List<Symbol> _symbols;
	
	public AnyOf(HashSet<Symbol> symbols) {
	    _symbols = new ArrayList<Symbol>();
	    Symbol empty = null;
	    for (Symbol s : symbols) {
	        if (s.isEmpty()) {
	            empty = s;
	        } else {
	            _symbols.add(s);
	        }
	    }
	    if (empty != null) {
	        _symbols.add(empty);
	    }
	}

	@Override
	public boolean parse(Interpreter in) throws IOException {
	    if (allowEOFSet() && in.getInput().atEOF()) {
	        return _allowEOF;
	    }
		for (Symbol s : _symbols) {
			if (s.parse(in)) {
				return true;
			}
		}
		return false;
	}
	
	@Override
	public String toString() {
		String out = "(";
		boolean first = true;
		for (Symbol s : _symbols) {
			if (first) {
				first = false;
			} else {
				out += " ";
			}
			out += s.toString();
		}
		out += ")";
		return out;
	}
    
    @Override
    public boolean isEmpty() {
        return _symbols.size() == 0;
    }
	
}
