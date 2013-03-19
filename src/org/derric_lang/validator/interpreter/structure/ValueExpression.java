package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

import org.derric_lang.validator.ValueSet;

public abstract class ValueExpression extends ValueSetExpression {
	
	public abstract Object eval(Map<String, Type> globals, Map<String, Type> locals);
	
	public ValueSet eval(ValueSet vs, Map<String, Type> globals, Map<String, Type> locals) {
		vs.addEquals((Long)eval(globals, locals));
		return vs;
	}

}
