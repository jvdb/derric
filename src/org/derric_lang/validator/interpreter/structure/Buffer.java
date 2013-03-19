package org.derric_lang.validator.interpreter.structure;

import org.derric_lang.validator.SubStream;

public class Buffer extends Type {
	
	private final SubStream _buffer;
	
	public Buffer() {
		_buffer = new SubStream();
	}
	
	public SubStream getSubStream() {
		return _buffer;
	}

}
