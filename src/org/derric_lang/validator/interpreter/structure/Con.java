package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

public class Con extends ValueExpression {
	
	private final long _value;
	
	public Con(java.lang.Integer value) {
		_value = value.longValue();
	}

	@Override
	public Object eval(Map<String, Type> globals, Map<String, Type> locals) {
		return _value;
	}

}
