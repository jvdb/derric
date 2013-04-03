package org.derric_lang.validator;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import org.derric_lang.validator.interpreter.FieldMatch;
import org.derric_lang.validator.interpreter.Interpreter;
import org.derric_lang.validator.interpreter.StructureMatch;
import org.derric_lang.validator.interpreter.structure.Decl;
import org.derric_lang.validator.interpreter.structure.Structure;
import org.derric_lang.validator.interpreter.symbol.Symbol;
import org.eclipse.imp.pdb.facts.IBool;
import org.eclipse.imp.pdb.facts.IConstructor;
import org.eclipse.imp.pdb.facts.IInteger;
import org.eclipse.imp.pdb.facts.IList;
import org.eclipse.imp.pdb.facts.IListWriter;
import org.eclipse.imp.pdb.facts.IMap;
import org.eclipse.imp.pdb.facts.ISet;
import org.eclipse.imp.pdb.facts.ISourceLocation;
import org.eclipse.imp.pdb.facts.IString;
import org.eclipse.imp.pdb.facts.IValue;
import org.eclipse.imp.pdb.facts.IValueFactory;

public class ExecuteInterpreter {
	
	public final static String PACKAGE = "org.derric_lang.validator.interpreter";
	
	private final IValueFactory _values;

	public ExecuteInterpreter(IValueFactory values) {
		super();
		_values = values;
	}
	
	public IValue executeValidator(IString format, IList sequence, IList structs, IList globals, ISourceLocation inputPath) {
		if (sequence.isEmpty()) throw new RuntimeException("Argument sequence may not be empty.");
		if (structs.isEmpty()) throw new RuntimeException("Argument structs may not be empty.");

		try {
			@SuppressWarnings("unchecked")
			Interpreter interpreter = new Interpreter(inputPath.getURI(), format.getValue(), (List<Symbol>)instantiate(sequence, PACKAGE + ".symbol"), (List<Structure>)instantiate(structs, PACKAGE + ".structure"), (List<Decl>)instantiate(globals, PACKAGE + ".structure"));
			ParseResult result = interpreter.tryParse();
			System.out.println(result);
			IListWriter lw = _values.listWriter();
			for (StructureMatch s : interpreter.getCurrent().getMatches()) {
			    IString name = _values.string(s.name);
			    ISourceLocation seqLoc = _values.sourceLocation(s.sequenceLocation.getURI(), s.sequenceLocation.getOffset(), s.sequenceLocation.getLength(), s.sequenceLocation.getBeginLine(), s.sequenceLocation.getEndLine(), s.sequenceLocation.getBeginColumn(), s.sequenceLocation.getEndColumn());
                ISourceLocation strLoc = _values.sourceLocation(s.structureLocation.getURI(), s.structureLocation.getOffset(), s.structureLocation.getLength(), s.structureLocation.getBeginLine(), s.structureLocation.getEndLine(), s.structureLocation.getBeginColumn(), s.structureLocation.getEndColumn());
                ISourceLocation inpLoc = _values.sourceLocation(s.inputLocation.getURI(), s.inputLocation.getOffset(), s.inputLocation.getLength());
                IListWriter flw = _values.listWriter();
                for (FieldMatch f : s.fields) {
                    flw.append(_values.tuple(_values.string(f.name), f.sourceLocation, f.inputLocation));
                }
                lw.append(_values.tuple(name, seqLoc, strLoc, inpLoc, flw.done()));
			}
			return _values.tuple(_values.bool(result.isSuccess()), lw.done());
		} catch(Exception e) {
			e.printStackTrace();
			System.out.println("Exception: " + e.getClass() + "; Message: " + e.getMessage());
		}
		return null;
	}
	
	private Object instantiate(IValue val, String pName) throws ClassNotFoundException, InstantiationException, IllegalAccessException, SecurityException, NoSuchMethodException, IllegalArgumentException, InvocationTargetException {
		if (val instanceof IString) {
			//System.out.println("Constructed String: " + ((IString)val).getValue());
			return ((IString)val).getValue();
		} else if (val instanceof IInteger) {
			//System.out.println("Constructed Integer: " + ((IInteger)val).intValue());
			return ((IInteger)val).intValue();
		} else if (val instanceof IBool) {
			//System.out.println("Constructed Boolean: " + ((IBool)val).getValue());
			return ((IBool)val).getValue();
		} else if (val instanceof ISourceLocation) {
			//System.out.println("Passed ISourceLocation: " + ((ISourceLocation)val).getURI());
			return val;
		} else if (val instanceof IList) {
			IList lval = (IList)val;
			ArrayList<Object> list = new ArrayList<Object>();
			for (int i = 0; i < lval.length(); i++) {
				list.add(instantiate(lval.get(i), pName));
			}
			//System.out.println("Constructed List: " + list);
			return list;
		} else if (val instanceof IMap) {
			IMap mval = (IMap)val;
			HashMap<Object, Object> map = new HashMap<Object, Object>();
			for (IValue key : mval) {
				map.put(instantiate(key, pName), instantiate(mval.get(key), pName));
			}
			//System.out.println("Constructed Map: " + map);
			return map;
		} if (val instanceof ISet) {
			ISet sval = (ISet)val;
			HashSet<Object> set = new HashSet<Object>();
			for (IValue item : sval) {
				set.add(instantiate(item, pName));
			}
			//System.out.println("Constructed Set: " + set);
			return set;
		} else if (val instanceof IConstructor) {
			IConstructor cval = (IConstructor)val;
			ArrayList<Object> args = new ArrayList<Object>();
			for (IValue arg : cval) {
				args.add(instantiate(arg, pName));
			}
			Class<?>[] argTypes = new Class<?>[args.size()];
			for (int i = 0; i < args.size(); i++) {
				argTypes[i] = args.get(i).getClass();
			}
			String typeName = pName + "." + capitalize(cval.getName());
			Class<?> c = Class.forName(typeName);
			Constructor<?> cons = null;
			Constructor<?>[] ca = c.getConstructors();
			for (Constructor<?> con : ca) {
				if (con.getParameterTypes().length == args.size()) {
					cons = con;
				}
			}
			if (cons != null) {
				//System.out.println("Constructed Constructor: " + cons);
				Object ins = cons.newInstance(args.toArray());
				Map<String, IValue> ans = cval.getAnnotations();
				//if (ans.size() > 0) {
				//	System.out.println("Annotations on " + typeName + ":" + ans);
				//}
				for (String key : ans.keySet()) {
				    Method[] ms = c.getMethods();
				    for (Method m : ms) {
				        if (m.getName().equals("set" + capitalize(key))) {
		                    m.invoke(ins, new Object[] { instantiate(ans.get(key), pName)});
		                    break;
				        }
				    }
				}
				return ins;
			}
		}
		throw new RuntimeException("Unsupported type encountered: " + val.getType());
	}
	
	private String capitalize(String in) {
		if (in.length() == 0) return in;
		return in.substring(0, 1).toUpperCase() + in.substring(1);
	}

}
