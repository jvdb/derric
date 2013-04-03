package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.Sentence;

public class Calc extends Statement {
	
	private final String _name;
	private final ValueExpression _exp;
	
	public Calc(String name, ValueExpression exp) {
		_name = name;
		_exp = exp;
	}
	
	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) {
		Type type = null;
		if (globals.containsKey(_name)) {
			type = globals.get(_name);
		} else if (locals.containsKey(_name)) {
			type = locals.get(_name);
		} else {
			throw new RuntimeException("Unknown variable referenced in Calc statement: " + this);
		}
		
		if (!(type instanceof Integer)) {
			throw new RuntimeException("Only integers supported in Calc statements: " + this);
		}
		Integer value = (Integer)type;
		value.setValue((Long)_exp.eval(globals, locals));
		return true;
	}

}
