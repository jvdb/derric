package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

import org.derric_lang.validator.ValueSet;

public abstract class ValueSetExpression extends Expression {
	
	public abstract ValueSet eval(ValueSet vs, Map<String, Type> globals, Map<String, Type> locals);

}
