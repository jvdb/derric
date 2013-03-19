package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;

public class SkipValue extends Statement {
	
	private final Type _type;
	
	public SkipValue(Type type) {
		_type = type;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals) throws IOException {
		if (!(_type instanceof Integer)) {
			throw new RuntimeException("SkipValue can only be instantiated with an Integer type: " + this);
		}
		return input.skipBits(((Integer)_type).getBits());
	}

}
