package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

public class Pow extends ValueExpression {
	
	private final ValueExpression _base;
	private final ValueExpression _exp;
	
	public Pow(ValueExpression base, ValueExpression exp) {
		_base = base;
		_exp = exp;
	}

	@Override
	public Object eval(Map<String, Type> globals, Map<String, Type> locals) {
		return (long)Math.pow((Long)_base.eval(globals, locals), (Long)_exp.eval(globals, locals));
	}

}
