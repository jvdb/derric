package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

public class Fac extends ValueExpression {
	
	private final ValueExpression _l;
	private final ValueExpression _r;
	
	public Fac(ValueExpression l, ValueExpression r) {
		_l = l;
		_r = r;
	}

	@Override
	public Object eval(Map<String, Type> globals, Map<String, Type> locals) {
		return (Long)_l.eval(globals, locals) * (Long)_r.eval(globals, locals);
	}

}
