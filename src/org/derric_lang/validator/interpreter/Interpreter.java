package org.derric_lang.validator.interpreter;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.derric_lang.validator.ParseResult;
import org.derric_lang.validator.Validator;
import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.structure.Decl;
import org.derric_lang.validator.interpreter.structure.Structure;
import org.derric_lang.validator.interpreter.structure.Type;
import org.derric_lang.validator.interpreter.symbol.Symbol;

public class Interpreter extends Validator {
	
	private final String _format;
	private final List<Symbol> _sequence;
	private final List<Structure> _structures;
	
	private final Map<String, Type> _globals;

	public Interpreter(String format, List<Symbol> sequence, List<Structure> structures, List<Decl> globals) {
		super(format);
		_format = format;
		_sequence = sequence;
		_structures = structures;
		_globals = new HashMap<String, Type>();
		for (Decl d : globals) {
			_globals.put(d.getName(), d.getType());
		}
	}

	@Override
	public String getExtension() {
		return _format;
	}

	@Override
	protected ParseResult tryParseBody() throws IOException {
		for (Symbol s : _sequence) {
			if (!s.parse(this)) {
				return new ParseResult(false, 0, 0, "A", "A B C");
			}
			System.out.println("Validated " + s.toString());
		}
		return new ParseResult(true, 0, 0, "A", "A B C");
	}

	@Override
	public ParseResult findNextFooter() throws IOException {
		return null;
	}
	
	public boolean parseStructure(String name) throws IOException {
	    for (Structure s : _structures) {
	        if (name.equals(s.getName())) {
	        	if (s.parse(_input, _globals)) {
	        		System.out.println("Structure " + s.getName() + " matched!");
	        		return true;
	        	} else {
	        		return false;
	        	}
	        }
	    }
	    throw new RuntimeException("Unknown structure requested: " + name);
	}
	
	public ValidatorInputStream getInput() {
	    return _input;
	}
	
}
