package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.Sentence;

public class ReadBuffer extends Statement {
	
	private final String _sizeVar;
	private final String _name;
	
	public ReadBuffer(String sizeVar, String name) {
		_sizeVar = sizeVar;
		_name = name;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) throws IOException {
	    long offset = input.lastLocation();
		long size = Expression.getIntegerValue(_sizeVar, globals, locals);
		Expression.getBuffer(_name, globals, locals).getSubStream().addFragment(input, size);
		current.addFieldLocation(getFieldName(), getLocation(), (int)offset, (int)(input.lastLocation() - offset));
		return true;
	}

}
