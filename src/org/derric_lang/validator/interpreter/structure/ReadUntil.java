package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.derric_lang.validator.ByteOrder;
import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.ValueSet;
import org.derric_lang.validator.interpreter.Sentence;

public class ReadUntil extends Statement {
	
	private final Integer _type;
	private final List<ValueSetExpression> _options;
	private final boolean _includeMarker;
	
	public ReadUntil(Integer type, List<ValueSetExpression> options, Boolean includeMarker) {
		_type = type;
		_options = options;
		_includeMarker = includeMarker;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) throws IOException {
        long offset = input.lastLocation();
		if (_type.getSign()) {
			input.signed();
		} else {
			input.unsigned();
		}
		if (_type.isBigEndian()) {
			input.byteOrder(ByteOrder.BIG_ENDIAN);
		} else {
			input.byteOrder(ByteOrder.LITTLE_ENDIAN);
		}
		input.includeMarker(_includeMarker);
		ValueSet vs = new ValueSet();
		for (ValueSetExpression vse : _options) {
			vs = vse.eval(vs, globals, locals);
		}
		boolean result = input.readUntil(_type.getBits(), vs).validated;
		if (result) {
		    current.addFieldLocation(getFieldName(), getLocation(), (int)offset, (int)(input.lastLocation() - offset));
		}
		return result;
	}

}
