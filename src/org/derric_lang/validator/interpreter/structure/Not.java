package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

import org.derric_lang.validator.ValueSet;

public class Not extends ValueSetExpression {
	
	private final ValueSetExpression _exp;
	
	public Not(ValueSetExpression exp) {
		_exp = exp;
	}

	@Override
	public ValueSet eval(ValueSet vs, Map<String, Type> globals, Map<String, Type> locals) {
		if (_exp instanceof Range) {
			Range r = (Range)_exp;
			vs.addNot((Long)r.getLower().eval(globals, locals), (Long)r.getUpper().eval(globals, locals));
			return vs;
		} else if (_exp instanceof ValueExpression) {
			ValueExpression ve = (ValueExpression)_exp;
			vs.addNot((Long)ve.eval(globals,  locals));
			return vs;
		} else {
			throw new RuntimeException("Only Range on ValueExpression objects allowed in a Not object: " + this);
		}
	}

}
