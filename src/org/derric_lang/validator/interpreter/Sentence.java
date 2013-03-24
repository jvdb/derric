package org.derric_lang.validator.interpreter;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.imp.pdb.facts.ISourceLocation;

public class Sentence {
	
	private String _structureName;
	private ISourceLocation _sequenceLocation;
	private ISourceLocation _structureLocation;
	private ISourceLocation _inputLocation;
	
	private List<StructureMatch> _matches;
	private List<StructureMatch> _sub;
	
	public Sentence() {
		_matches = new ArrayList<StructureMatch>();
		_sub = new ArrayList<StructureMatch>();
	}
	
	public void setName(String name) {
		_structureName = name;
	}
	
	public void setSequenceLocation(ISourceLocation location) {
		_sequenceLocation = location;
	}
	
	public void setStructureLocation(ISourceLocation location) {
		_structureLocation = location;
	}
	
	public void setInputLocation(ISourceLocation location) {
		_inputLocation = location;
	}
	
	public void subMatch() {
		_sub.add(new StructureMatch(_structureName, _sequenceLocation, _structureLocation, _inputLocation));
	}
	
	public void fullMatch() {
		_matches.addAll(_sub);
		clearSub();
	}
	
	public void clearSub() {
		_sub.clear();
	}
    
    @Override
    public String toString() {
        String out = "";
        boolean first = true;
        for (StructureMatch s : _matches) {
            if (first) {
                first = false;
            } else {
                out += " ";
            }
            out += s.name;
        }
        return out;
    }
    
    public List<StructureMatch> getMatches() {
        return _matches;
    }
    
}
