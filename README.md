**LevelDB - Swift**

*A Swift wrapper for [LevelDB](http://leveldb.googlecode.com)*

This is a pure Swift wrapper around the LevelDB C API, configured to build OS X & iOS dynamic frameworks for your convenience. It's a minimal, low-level wrapper without a lot of the usual convenience methods (subscripts, string keys, queries etc). The goal is to eventually expose all of the LevelDB functionality with a reasonably idiomatic Swift API, so that more sophisticated mobile database frameworks can be built on top. 

The current version should be considered an ALPHA release and the API will probably change from here. 

Basic usage:

	let db = Database.createDatabase(directory, options: Options(createIfMissing:true))
	db.put(key, value: value)
	db.get(key)

WriteBatch support:

	let batch = WriteBatch()
	batch.put(key1, value1)
	batch.delete(key2)
	db.write(batch)

Iterators:

	let iter = db.newIterator()
	iter.seek(startKey)
	while iter.next() {
		NSLog("%@: %@", iter.key, iter.value)
	}

Custom Swift Comparator class. This required some C glue code - I'm not the world best C programmer, so there's a good chance I've stuffed up something really basic.

	class MyCustomComparator : Comparator {
		var name : String {
			get {
				return "MyCustomComparator"
			}
		}
		
		func compare(a : NSData, _ b : NSData) -> NSComparisonResult 		{
			let string1 = NSString(data: a, encoding: NSUTF8StringEncoding)
			let string2 = NSString(data: a, encoding: NSUTF8StringEncoding)
			return string1.compare(string2)
		}
	}

Note that all keys & values are NSData instances, as this is the closest Foundation equivalent to LevelDB's Slice, and allows the use of binary keys (to keep Andy happy). I'll probably end up adding convenience methods for String keys; in the meantime you can do it yourself using something like:

	extension Database {
		subscript(index: String) -> NSData? {
			get {
				return self.get(index.dataUsingEncoding(NSUTF8StringEncoding))
			}
			set(newValue) {
				self.set(index.dataUsingEncoding(NSUTF8StringEncoding)), value: newValue)
			}
		}
	}

The LevelDB source is included as a submodule (run `git submodule init && git submodule update` if you've cloned the source). It's compiled into the framework targets directly by Xcode rather than using an external build target because I rage-quit the LevelDB Makefile.

The TODO list:

* Implement filter policy support
* More code comments & better doco
* Better failure indication than NSLog messages
* Enable Snappy compression?
* Snapshot might be better as a trailing closure method 
* Rethink Iterator API
* DB properties, compact & cache support


Copyright © 2104, codesplice pty ltd

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.