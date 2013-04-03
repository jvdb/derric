package org.derric_lang.validator.interpreter;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.imp.pdb.facts.ISourceLocation;

public class Sentence {
    
    private final URI _inputFile;
	
	private String _structureName;
	private ISourceLocation _sequenceLocation;
	private ISourceLocation _structureLocation;
	private ISourceLocation _inputLocation;
	
	private List<StructureMatch> _matches;
	private List<StructureMatch> _sub;
	private List<FieldMatch> _fields;
	
	public Sentence(URI inputFile) {
	    _inputFile = inputFile;
		_matches = new ArrayList<StructureMatch>();
		_sub = new ArrayList<StructureMatch>();
		_fields = new ArrayList<FieldMatch>();
	}
	
	public void setStructureName(String name) {
		_structureName = name;
	}
	
	public void setSequenceLocation(ISourceLocation location) {
		_sequenceLocation = location;
	}
	
	public void setStructureLocation(ISourceLocation location) {
		_structureLocation = location;
	}
	
	public void setStructureInputLocation(int offset, int length) {
	    _inputLocation = new SourceLocation(_inputFile, offset, length);
	}
	
	public void addFieldLocation(String name, ISourceLocation sourceLocation, int offset, int length) {
	    boolean dup = false;
	    int index = 0;
	    for (int i = 0; i < _fields.size(); i++) {
            if (_fields.get(i).sourceLocation.getOffset() == sourceLocation.getOffset() && _fields.get(i).sourceLocation.getLength() == sourceLocation.getLength()) {
                dup = true;
                index = i;
                String fName = _fields.get(i).name.length() > name.length() ? name : _fields.get(i).name;
                int fOffset = _fields.get(i).inputLocation.getOffset() > offset ? offset : _fields.get(i).inputLocation.getOffset();
                int fLength = ((_fields.get(i).inputLocation.getOffset() + _fields.get(i).inputLocation.getLength()) > (offset + length) ? _fields.get(i).inputLocation.getOffset() + _fields.get(i).inputLocation.getLength() : offset + length) - fOffset;
                FieldMatch fm = new FieldMatch(fName, sourceLocation, new SourceLocation(_inputFile, fOffset, fLength));
                _fields.add(index, fm);
                _fields.remove(index + 1);
                break;
            }
	    }
	    if (!dup) {
	        _fields.add(new FieldMatch(name, sourceLocation, new SourceLocation(_inputFile, offset, length)));
	    }
	}
	
	public void subMatch() {
	    List<FieldMatch> fieldMatches = new ArrayList<FieldMatch>();
	    fieldMatches.addAll(_fields);
		_sub.add(new StructureMatch(_structureName, _sequenceLocation, _structureLocation, _inputLocation, fieldMatches));
		_fields.clear();
	}
	
	public void fullMatch() {
		_matches.addAll(_sub);
		clearSub();
	}
	
	public void clearSub() {
		_sub.clear();
		_fields.clear();
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
