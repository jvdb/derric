package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.Map;

import org.derric_lang.validator.ByteOrder;
import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.Sentence;

public class ReadValue extends Statement {
	
	private final Integer _type;
	private final String _name;
	
	public ReadValue(Type type, String name) {
		_type = (Integer)type;
		_name = name;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) throws IOException {
        long offset = input.lastLocation();
		Integer value = Expression.getInteger(_name, globals, locals);
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
		value.setValue(input.readInteger(_type.getBits()));
        current.addFieldLocation(getFieldName(), getLocation(), (int)offset, (int)(input.lastLocation() - offset));
		return true;
	}

}
