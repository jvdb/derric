package org.derric_lang.validator.interpreter;

import java.util.List;

import org.eclipse.imp.pdb.facts.ISourceLocation;

public class StructureMatch {
	
	public final String name;
	public final ISourceLocation sequenceLocation;
	public final ISourceLocation structureLocation;
	public final ISourceLocation inputLocation;
	public final List<FieldMatch> fields;
	
	public StructureMatch(String name, ISourceLocation sequenceLocation, ISourceLocation structureLocation, ISourceLocation inputLocation, List<FieldMatch> fields) {
		this.name = name;
		this.sequenceLocation = sequenceLocation;
		this.structureLocation = structureLocation;
		this.inputLocation = inputLocation;
		this.fields = fields;
	}
	
}
