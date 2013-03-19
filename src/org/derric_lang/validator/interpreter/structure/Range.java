package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

import org.derric_lang.validator.ValueSet;

public class Range extends ValueSetExpression {
	
	private final ValueExpression _lower;
	private final ValueExpression _upper;
	
	public Range(ValueExpression lower, ValueExpression upper) {
		_lower = lower;
		_upper = upper;
	}
	
	public ValueExpression getLower() {
		return _lower;
	}
	
	public ValueExpression getUpper() {
		return _upper;
	}
	
	@Override
	public ValueSet eval(ValueSet vs, Map<String, Type> globals, Map<String, Type> locals) {
		vs.addEquals((Long)_lower.eval(globals,  locals), (Long)_upper.eval(globals, locals));
		return vs;
	}

}
