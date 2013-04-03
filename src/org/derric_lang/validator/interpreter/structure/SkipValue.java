package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.Sentence;

public class SkipValue extends Statement {
	
	private final Type _type;
	
	public SkipValue(Type type) {
		_type = type;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) throws IOException {
		if (!(_type instanceof Integer)) {
			throw new RuntimeException("SkipValue can only be instantiated with an Integer type: " + this);
		}
        long offset = input.lastLocation();
        boolean result = input.skipBits(((Integer)_type).getBits());
        if (result) {
            current.addFieldLocation(getFieldName(), getLocation(), (int)offset, (int)(input.lastLocation() - offset));
        }
		return result;
	}

}
