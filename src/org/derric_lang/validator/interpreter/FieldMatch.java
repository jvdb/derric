package org.derric_lang.validator.interpreter;

import org.eclipse.imp.pdb.facts.ISourceLocation;

public class FieldMatch {
    
    public final String name;
    public final ISourceLocation sourceLocation;
    public final ISourceLocation inputLocation;
    
    public FieldMatch(String name, ISourceLocation sourceLocation, ISourceLocation inputLocation) {
        this.name = name;
        this.sourceLocation = sourceLocation;
        this.inputLocation = inputLocation;
    }

}
