package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

public abstract class Expression {
	
	public static Object getVariable(String name, Map<String, Type> globals, Map<String, Type> locals) {
		if (globals.containsKey(name)) {
			return globals.get(name);
		} else if (locals.containsKey(name)) {
			return locals.get(name);
		} else {
			throw new RuntimeException("Unknown variable referenced: " + name);
		}
	}
	
	public static Integer getInteger(String name, Map<String, Type> globals, Map<String, Type> locals) {
		Object o = getVariable(name, globals, locals);
		if (o instanceof Integer) {
			return (Integer)o;
		} else {
			throw new RuntimeException("Unknown Integer variable referenced: " + name);
		}
	}
	
	public static long getIntegerValue(String name, Map<String, Type> globals, Map<String, Type> locals) {
		return getInteger(name, globals, locals).getValue();
	}
	
	public static Buffer getBuffer(String name, Map<String, Type> globals, Map<String, Type> locals) {
		Object o = getVariable(name, globals, locals);
		if (o instanceof Buffer) {
			return (Buffer)o;
		} else {
			throw new RuntimeException("Unknown Buffer variable referenced: " + name);
		}
	}
}
