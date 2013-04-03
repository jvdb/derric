package org.derric_lang.validator.interpreter.structure;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.derric_lang.validator.Content;
import org.derric_lang.validator.SubStream;
import org.derric_lang.validator.ValidatorInputStream;
import org.derric_lang.validator.interpreter.Sentence;

public class ValidateContent extends Statement {
	
	private final String _name;
	private final String _sizeName;
	private final String _methodName;
	private final Map<String, String> _custom;
	private final Map<String, List<ValueExpression>> _references;
	private final boolean _allowEOF;
	
	public ValidateContent(String name, String sizeName, String methodName, Map<String, String> custom, Map<String, List<ValueExpression>> references, Boolean allowEOF) {
		_name = name;
		_sizeName = sizeName;
		_methodName = methodName;
		_custom = custom;
		_references = references;
		_allowEOF = allowEOF;
	}

	@Override
	public boolean eval(ValidatorInputStream input, Map<String, Type> globals, Map<String, Type> locals, Sentence current) throws IOException {
        long offset = input.lastLocation();
		SubStream buffer = Expression.getBuffer(_name, globals, locals).getSubStream();
		Integer size = Expression.getInteger(_sizeName, globals, locals);
		Map<String, List<Object>> references = new HashMap<String, List<Object>>();
		for (String key : _references.keySet()) {
			List<ValueExpression> exps = _references.get(key);
			ArrayList<Object> objs = new ArrayList<Object>();
			for (ValueExpression ve : exps) {
				objs.add(ve.eval(globals, locals));
			}
			references.put(key, objs);
		}
		Content content = input.validateContent(size.getValue(), _methodName, _custom, references, _allowEOF);
		if (!content.validated) {
			return false;
		}
		buffer.fragments.add(content.data);
		size.setValue(buffer.getLast().length);
        current.addFieldLocation(getFieldName(), getLocation(), (int)offset, (int)(input.lastLocation() - offset));
		return true;
	}

}
