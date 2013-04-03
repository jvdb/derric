package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.Sentence;
import org.eclipse.imp.pdb.facts.ISourceLocation;


public class Structure {
	
	private final String _name;
	private final Map<String, Type> _locals;
	private final List<Statement> _statements;
	private ISourceLocation _location;
	
	public Structure(String name, ArrayList<Statement> statements) {
		_name = name;
		_locals = new HashMap<String, Type>();
		_statements = new ArrayList<Statement>();
		for (Statement s : statements) {
			if (s instanceof Decl) {
				_locals.put(((Decl)s).getName(), ((Decl)s).getType());
			} else {
				_statements.add(s);
			}
		}
	}
	
	public void setLocation(ISourceLocation location) {
		_location = location;
	}
	
	public ISourceLocation getLocation() {
		return _location;
	}
	
	public String getName() {
	    return _name;
	}
	
	public boolean parse(ValidatorInputStream input, Map<String, Type> globals, Sentence current) throws IOException {
		long markStart = input.lastLocation();
		for (Statement s : _statements) {
			if (!s.eval(input, globals, _locals, current)) {
				input.skip(markStart - input.lastLocation());
				return false;
			}
		}
		return true;
	}

}
