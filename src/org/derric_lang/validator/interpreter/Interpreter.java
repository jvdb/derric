package org.derric_lang.validator.interpreter;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.derric_lang.validator.ParseResult;
import org.derric_lang.validator.Validator;
import org.derric_lang.validator.interpreter.structure.Decl;
import org.derric_lang.validator.interpreter.structure.GdeclB;
import org.derric_lang.validator.interpreter.structure.GdeclV;
import org.derric_lang.validator.interpreter.structure.Structure;
import org.derric_lang.validator.interpreter.symbol.Symbol;

public class Interpreter extends Validator {
	
	private final String _format;
	private final List<Symbol> _sequence;
	private final List<Structure> _structures;
	
	public final Map<String, Long> values;
	public final Map<String, byte[]> buffers;

	public Interpreter(String format, List<Symbol> sequence, List<Structure> structures, List<Decl> globals) {
		super(format);
		_format = format;
		_sequence = sequence;
		_structures = structures;
		values = new HashMap<String, Long>();
		buffers = new HashMap<String, byte[]>();
		for (Decl d : globals) {
			if (d instanceof GdeclV) {
				values.put(d.getName(), 0l);
			} else if (d instanceof GdeclB) {
				buffers.put(d.getName(), null);
			}
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
		}
		return new ParseResult(true, 0, 0, "A", "A B C");
	}

	@Override
	public ParseResult findNextFooter() throws IOException {
		return null;
	}
	
	public Structure getStructure(String name) {
	    for (Structure s : _structures) {
	        if (name.equals(s.getName())) {
	            return s;
	        }
	    }
	    throw new RuntimeException("Unknown structures requested: " + name);
	}
}
