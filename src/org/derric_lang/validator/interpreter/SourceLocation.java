package org.derric_lang.validator.interpreter;

import java.net.URI;

import org.eclipse.imp.pdb.facts.ISourceLocation;
import org.eclipse.imp.pdb.facts.IValue;
import org.eclipse.imp.pdb.facts.type.Type;
import org.eclipse.imp.pdb.facts.type.TypeFactory;
import org.eclipse.imp.pdb.facts.visitors.IValueVisitor;
import org.eclipse.imp.pdb.facts.visitors.VisitorException;

public class SourceLocation implements ISourceLocation {
	
	private final URI _uri;
	private final int _offset;
	private final int _length;
	
	public SourceLocation(URI uri, int offset, int length) {
		_uri = uri;
		_offset = offset;
		_length = length;
	}

	@Override
	public Type getType() {
		return TypeFactory.getInstance().sourceLocationType();
	}

	@Override
	public <T> T accept(IValueVisitor<T> v) throws VisitorException {
		return v.visitSourceLocation(this);
	}

	@Override
	public boolean isEqual(IValue other) {
		if (other == null || getClass() != other.getClass()) {
			return false;
		}
		ISourceLocation o = (ISourceLocation)other;
		return (hasOffsetLength() == o.hasOffsetLength() &&
				hasLineColumn() == o.hasLineColumn() &&
				getURI() == o.getURI() &&
				getOffset() == o.getOffset() &&
				getLength() == o.getLength());
	}

	@Override
	public URI getURI() {
		return _uri;
	}

	@Override
	public boolean hasOffsetLength() {
		return true;
	}

	@Override
	public boolean hasLineColumn() {
		return false;
	}

	@Override
	public int getOffset() throws UnsupportedOperationException {
		return _offset;
	}

	@Override
	public int getLength() throws UnsupportedOperationException {
		return _length;
	}

	@Override
	public int getBeginLine() throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}

	@Override
	public int getEndLine() throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}

	@Override
	public int getBeginColumn() throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}

	@Override
	public int getEndColumn() throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}
}
