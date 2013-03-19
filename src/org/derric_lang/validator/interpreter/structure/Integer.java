package org.derric_lang.validator.interpreter.structure;

public class Integer extends Type {
	
	private final boolean _signed;
	private final boolean _bigEndian;
	private final int _bits;
	private long _value;
	
	public Integer(Boolean signed, Endianness endianness, java.lang.Integer bits) {
		_signed = signed;
		_bigEndian = endianness instanceof Big;
		_bits = bits;
	}
	
	public boolean getSign() {
		return _signed;
	}
	
	public boolean isBigEndian() {
		return _bigEndian;
	}
	
	public int getBits() {
		return _bits;
	}
	
	public long getValue() {
		return _value;
	}
	
	public void setValue(long value) {
		_value = value;
	}

}
