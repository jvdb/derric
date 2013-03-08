package org.derric_lang.validator.interpreter;

import java.io.IOException;
import java.util.List;

import org.derric_lang.validator.ParseResult;
import org.derric_lang.validator.Validator;
import org.derric_lang.validator.interpreter.structure.Structure;
import org.derric_lang.validator.interpreter.symbol.Symbol;

public class Interpreter extends Validator {
	
	private final String _format;

	public Interpreter(String format, List<Symbol> sequence, List<Structure> structures) {
		super(format);
		_format = format;
	}

	@Override
	public String getExtension() {
		return _format;
	}

	@Override
	protected ParseResult tryParseBody() throws IOException {
		return new ParseResult(false, 0, 0, "A", "A B C");
	}

	@Override
	public ParseResult findNextFooter() throws IOException {
		return null;
	}
}
