package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;

public class SkipBuffer extends Statement {
	
	private final String _sizeVar;
	
	public SkipBuffer(String sizeVar) {
		_sizeVar = sizeVar;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals) throws IOException {
		long value = Expression.getIntegerValue(_sizeVar, globals, locals);
		return input.skip(value) == value;
	}

}
