package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;

public abstract class Decl extends Statement {
	
	private final String _name;
	protected final Type _type;
	
	protected Decl(String name, Type type) {
		_name = name;
		_type = type;
	}
	
	public String getName() {
		return _name;
	}
	
	public Type getType() {
		return _type;
	}
	
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals) {
		return true;
	}
}
