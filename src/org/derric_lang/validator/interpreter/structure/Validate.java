package org.derric_lang.validator.interpreter.structure;

import java.util.List;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.ValueSet;
import org.derric_lang.validator.interpreter.Sentence;

public class Validate extends Statement {
	
	private final String _name;
	private final List<ValueSetExpression> _options;
	
	public Validate(String name, List<ValueSetExpression> options) {
		_name = name;
		_options = options;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) {
		long l = Expression.getIntegerValue(_name, globals, locals);
		ValueSet vs = new ValueSet();
		for (ValueSetExpression vse : _options) {
			vs = vse.eval(vs,  globals, locals);
		}
		return vs.equals(l);
	}

}
