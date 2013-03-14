package org.derric_lang.validator.interpreter.structure;

public abstract class Decl extends Statement {
	
	private final String _name;
	
	public Decl(String name) {
		_name = name;
	}
	
	public String getName() {
		return _name;
	}
}
