/* Copyright 2011-2012 Netherlands Forensic Institute and
                       Centrum Wiskunde & Informatica

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

package org.derric_lang.validator;

import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Map;

public class ValidatorInputStreamImpl extends ValidatorInputStream {

	private OrderedInputStream _in;
	private ContentValidator _cv;
	private boolean _sign;
	private boolean _includeMarker;

	private int _cache = 0;
	private int _bitsLeft = 0;

	private long _offset = 0;
	private long _lastRead = 0;

	public ValidatorInputStreamImpl(InputStream in, ContentValidator cv) {
		_in = new OrderedInputStream(in);
		_cv = cv;
		_sign = false;
		_includeMarker = false;
	}

	@Override
	public int available() throws IOException {
	  return _in.available();
	}

	@Override
	public boolean isByteAligned() {
		return _bitsLeft == 0;
	}
	
	@Override
	public boolean atEOF() throws IOException {
	  if (_bitsLeft > 0) return false;
	  if (_in.available() == 0) return true;
	  return false;
	}

	@Override
	public long lastLocation() {
		return _offset;
	}

	@Override
	public long lastRead() {
		return _lastRead - 1;
	}

	@Override
	public void mark() {
		_in.mark(0);
	}

	@Override
	public void reset() throws IOException {
	  if (_lastRead > _offset) {
	    _lastRead = _offset;
	  }
		_in.reset();
	}

	@Override
	public boolean skipBits(long bits) throws IOException {
    if (atEOF() && (bits > 0)) throw new EOFException();

		if (bits == 0) {
			return true;
		}
		if (bits < 0) {
			return false;
		}

		if (bits <= _bitsLeft) {
			// if everything is cached
			readInteger(bits);
			return true;
		}

		long skipReq = bits;
		if (_bitsLeft > 0) {
			// first clear out the cache
			skipReq -= _bitsLeft;
			_bitsLeft = 0;
		}

		// full bytes can be skipped
		long skipBytes = skipReq / 8;
		long skipped = skip(skipBytes);
		if (skipped != skipBytes) {
			return false;
		}

		// remaining bits are read
		long remainingBits = skipReq % 8;
		if (remainingBits > 0) {
			try {
				readInteger(remainingBits);
			} catch (EOFException e) {
				return false;
			}
		}

		return true;
	}
	
	@Override
	public long skip(long bytes) throws IOException {
    //if (atEOF() && (bytes > 0)) throw new EOFException();

	  _bitsLeft = 0;
	  long change = _in.skip(bytes);
	  _offset += change;
	  if (_offset > _lastRead) {
	    _lastRead = _offset;
	  }
		return change;
	}

	@Override
	public ValidatorInputStream bitOrder(BitOrder order) {
		_in.bitOrder(order);
		return this;
	}

	@Override
	public ValidatorInputStream byteOrder(ByteOrder order) {
		_in.byteOrder(order);
		return this;
	}

	@Override
	public ValidatorInputStream signed() {
		_sign = true;
		return this;
	}

	@Override
	public ValidatorInputStream unsigned() {
		_sign = false;
		return this;
	}

	@Override
	public long readInteger(long bits) throws IOException {
	  if (atEOF()) throw new EOFException();
		if (bits == 0) throw new RuntimeException("Cannot return value of length=0.");
		if (bits > 64) throw new RuntimeException("Cannot return value of length>64 in a long.");
		if (bits == 64 && !_sign)throw new RuntimeException("Cannot return an unsigned value of length=64 in a long.");
		if (_bitsLeft > 0 && bits > _bitsLeft) throw new RuntimeException("Values crossing byte boundaries are only supported when byte aligned.");
		if (bits > 8 && (bits % 8) > 0) throw new RuntimeException("Values crossing byte boundaries are only supported when a multiple of 8.");

		long ret = 0;
		long bitsReq = bits;

		// handle small values within a single byte with data in the cache
		if (_bitsLeft > 0) {
			int mask = (int) Math.pow(2, bitsReq) - 1 << _bitsLeft - bitsReq;
			ret = _cache & mask;
			_bitsLeft -= bitsReq;
			ret >>>= _bitsLeft;
			// handle byte aligned single- or multibyte values
		} else if ((bitsReq / 8) > 0) {
			int i = 0;
			byte[] data = new byte[(int) bitsReq / 8];
			read(data);
			_lastRead = _offset;
			//if (count < (bitsReq / 8)) return 0;
			for (; i < bitsReq / 8; i++) {
				long tmp = data[i] & 0xFF;
				ret <<= 8;
				ret |= tmp;
			}
			// handle small values within a single byte without data in the
			// cache
		} else if (bitsReq > 0) {
			_cache = read();
			if (_cache == -1) return 0;
			_lastRead = _offset;
			_bitsLeft = 8;
			int mask = (int) Math.pow(2, bitsReq) - 1 << _bitsLeft - bitsReq;
			ret |= (_cache & mask) >> (8 - bitsReq);
			_bitsLeft -= bitsReq;
		}

		// handle sign
		if (_sign && (ret & (long) Math.pow(2, bits - 1)) != 0) {
			ret -= (long) Math.pow(2, bits);
		}

		return ret;
	}

	@Override
	public ValidatorInputStream includeMarker(boolean includeMarker) {
		_includeMarker = includeMarker;
		return this;
	}

	@Override
	public Content readUntil(long bits, ValueSet values) throws IOException {
		boolean found = false;
		ByteArrayOutputStream out = new ByteArrayOutputStream(1024*1024);
		long read = 0l;
		while (!found) {
			read = readInteger(bits);
			if (values.equals(read)) {
				found = true;
			} else if (atEOF()) {
			  break;
			} else {
			  skip(0-(bits/8));
				out.write(read());
				//skipBits(8);
			}
		}
		if (!_includeMarker && found) {
		  skip(0-(bits/8));
		} else {
			byte[] marker = ByteBuffer.allocate(8).putLong(read).array();
			for (int i = 0; i < (bits / 8); i++) {
				out.write(marker[i]);
			}
		}
		return new Content(found, out.toByteArray());
	}

	@Override
	public Content validateContent(long size, String name, Map<String, String> configuration, Map<String, List<Object>> arguments, boolean allowEOF) throws IOException {
		return _cv.validateContent(this, size, name, configuration, arguments, allowEOF);
	}

    @Override
    public int read() throws IOException {
        int result = _in.read();
        if (result >= 0) {
            _offset++;
        }
        return result;
    }
    
    @Override
    public int read(byte[] b, int off, int len) throws IOException {
        int result = _in.read(b, off, len);
        if (result >= 0) {
            _offset += result;
        }
        return result;
    }
    
    @Override
    public int read(byte[] b) throws IOException {
        int result = _in.read(b);
        if (result >= 0) {
            _offset += result;
        }
        return result;
    }
    
}
