package org.derric_lang.validator.interpreter.symbol;

import java.util.HashSet;
import java.util.Set;

import org.derric_lang.validator.interpreter.Interpreter;

public class AnyOf extends Symbol {
	
	private final Set<Symbol> _symbols;
	
	public AnyOf(HashSet<Symbol> symbols) {
		_symbols = symbols;
	}

	@Override
	public boolean parse(Interpreter in) {
		for (Symbol s : _symbols) {
			if (s.parse(in)) {
				return true;
			}
		}
		return false;
	}

}
