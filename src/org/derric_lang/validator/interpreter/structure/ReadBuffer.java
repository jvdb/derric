package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;

public class ReadBuffer extends Statement {
	
	private final String _sizeVar;
	private final String _name;
	
	public ReadBuffer(String sizeVar, String name) {
		_sizeVar = sizeVar;
		_name = name;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals) throws IOException {
		long size = Expression.getIntegerValue(_sizeVar, globals, locals);
		Expression.getBuffer(_name, globals, locals).getSubStream().addFragment(input, size);
		return true;
	}

}
