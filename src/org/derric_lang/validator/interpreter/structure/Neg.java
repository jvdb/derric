package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

public class Neg extends ValueExpression {
	
	private final ValueExpression _exp;
	
	public Neg(ValueExpression exp) {
		_exp = exp;
	}

	@Override
	public Object eval(Map<String, Type> globals, Map<String, Type> locals) {
		return -(Long)_exp.eval(globals, locals);
	}

}
