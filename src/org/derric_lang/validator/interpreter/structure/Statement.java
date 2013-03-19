package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;

public abstract class Statement {
	
	public abstract boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals) throws IOException;

}
