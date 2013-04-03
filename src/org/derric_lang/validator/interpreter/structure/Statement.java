package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.Sentence;
import org.eclipse.imp.pdb.facts.ISourceLocation;

public abstract class Statement {
	
	private ISourceLocation _location;
	private String _fieldName;
	
	public void setLocation(ISourceLocation location) {
		_location = location;
	}
	
	public ISourceLocation getLocation() {
		return _location;
	}
	
	public void setFieldName(String fieldName) {
	    _fieldName = fieldName;
	}
	
	public String getFieldName() {
	    return _fieldName;
	}
	
	public abstract boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) throws IOException;

}
