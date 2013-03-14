package org.derric_lang.validator.interpreter.structure;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.derric_lang.validator.interpreter.Interpreter;


public class Structure {
	
	private final String _name;
	private final Map<String, Long> _values;
	private final Map<String, byte[]> _buffers;
	private final List<Statement> _statements;
	
	public Structure(String name, ArrayList<Statement> statements) {
		_name = name;
		_values = new HashMap<String, Long>();
		_buffers = new HashMap<String, byte[]>();
		_statements = new ArrayList<Statement>();
		for (Statement s : statements) {
			if (s instanceof LdeclV) {
				_values.put(((Decl)s).getName(), 0l);
			} else if (s instanceof LdeclB) {
				_buffers.put(((Decl)s).getName(), null);
			} else {
				_statements.add(s);
			}
		}
	}
	
	public String getName() {
	    return _name;
	}
	
	public boolean parse(Interpreter in) {
	    return false;
	}

}
