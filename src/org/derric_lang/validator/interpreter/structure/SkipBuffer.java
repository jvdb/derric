package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.Sentence;

public class SkipBuffer extends Statement {
	
	private final String _sizeVar;
	
	public SkipBuffer(String sizeVar) {
		_sizeVar = sizeVar;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) throws IOException {
        long offset = input.lastLocation();
		long value = Expression.getIntegerValue(_sizeVar, globals, locals);
		boolean result = input.skip(value) == value;
		if (result) {
		    current.addFieldLocation(getFieldName(), getLocation(), (int)offset, (int)(input.lastLocation() - offset));
		}
		return result;
	}

}
