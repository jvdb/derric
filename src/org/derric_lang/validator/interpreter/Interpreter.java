package org.derric_lang.validator.interpreter;

import java.io.IOException;
import java.net.URI;
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
	
	private Sentence _current;
	private URI _inputFile;

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
		_current = new Sentence();
		for (Symbol s : _sequence) {
			if (!s.parse(this)) {
			    return new ParseResult(false, _input.lastLocation(), _input.lastRead(), s.toString(), _current.toString());
			}
			_current.fullMatch();
			//System.out.println("Validated " + s.toString());
		}
        return new ParseResult(true, _input.lastLocation(), _input.lastRead(), "", _current.toString());
	}

	@Override
	public ParseResult findNextFooter() throws IOException {
		return null;
	}
	
	public void setInputFile(URI inputFile) {
		_inputFile = inputFile;
	}
	
	public boolean parseStructure(String name) throws IOException {
		long offset = _input.lastLocation();
	    for (Structure s : _structures) {
	        if (name.equals(s.getName())) {
	        	if (s.parse(_input, _globals)) {
	        		_current.setStructureLocation(s.getLocation());
	        		_current.setInputLocation(new SourceLocation(_inputFile, (int)offset, (int)(_input.lastLocation() - offset)));
	        		//System.out.println("Structure " + s.getName() + " matched!");
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
	
	public Sentence getCurrent() {
		return _current;
	}
	
}
