package org.derric_lang.validator.interpreter.structure;

import java.util.Map;

public class Var extends ValueExpression {
	
	private final String _name;
	
	public Var(String name) {
		_name = name;
	}

	@Override
	public Object eval(Map<String, Type> globals, Map<String, Type> locals) {
		Object o = Expression.getVariable(_name, globals, locals);
		if (o instanceof Integer) {
			return ((Integer)o).getValue();
		} else if (o instanceof Buffer) {
			return ((Buffer)o).getSubStream();
		} else {
			throw new RuntimeException("Unknown variable type encountered: " + this);
		}
	}
}
