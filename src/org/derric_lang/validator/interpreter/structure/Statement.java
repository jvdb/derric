package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;
import org.eclipse.imp.pdb.facts.ISourceLocation;

public abstract class Statement {
	
	private ISourceLocation _location;
	
	public void setLocation(ISourceLocation location) {
		_location = location;
	}
	
	public ISourceLocation getLocation() {
		return _location;
	}
	
	public abstract boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals) throws IOException;

}
