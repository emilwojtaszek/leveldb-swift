#LevelDB - Swift

##A Swift wrapper for [LevelDB](https://github.com/google/leveldb)*

This is a pure Swift wrapper around the LevelDB C API, configured to build OS X & iOS dynamic frameworks. It's a minimal, low-level wrapper without a lot of the usual convenience methods (subscripts, string keys, queries etc). The goal is to eventually expose all of the LevelDB functionality with a reasonably idiomatic Swift API, so that more sophisticated mobile database frameworks can be built on top. 

The current version should be considered an ALPHA release and the API will probably change from here. 

Basic usage:

	let db = try Database.createDatabase(directory, options: Options(createIfMissing: true))
	try db.put(key, value: value)
	try db.get(key)

WriteBatch support:

	let batch = WriteBatch()
	batch.put(key1, value1)
	batch.delete(key2)
	try db.write(batch)

The C++ style LevelDB iterator has been wrapped with Swift `SequenceType`s:

	for key: String in db.keys()
		print(key)
	}
  
	for (key, value) in db.values(from: startKey, to: endKey, descending: true)
		print("\(key): \(value)")
	}
  

Custom Swift Comparator class. This required some C glue code - I'm not the world's best C programmer, so there's a good chance I've stuffed up something really basic.

	class MyCustomComparator: Comparator {
		var name: String {
			get {
				return "MyCustomComparator"
			}
		}
		
	    func compare(a: LevelDB.Slice, _ b: LevelDB.Slice) -> NSComparisonResult {
	        let string1 = String(bytes: a.bytes, length: a.length)
	        let string2 = String(bytes: b.bytes, length: b.length)
	        return string1.compare(string2)
	    }
	}

Note that all values are NSData instances, as this is the closest Foundation equivalent to LevelDB's Slice, but this will probably change to a Swift type eventually. Keys must conform to `KeyType` - there are built in implementations for `String` and `NSData` to allow the use of binary keys (and keep Andy happy).

The LevelDB source is included as a submodule (run `git submodule init && git submodule update` if you've cloned the source). It's compiled into the framework targets directly by Xcode rather than using an external build target because I rage-quit the LevelDB Makefile.

The TODO list:

* Implement filter policy support
* More code comments & better doco
* Enable Snappy compression?
* Snapshot might be better as a trailing closure method 
* DB properties, compact & cache support
* Use `UnsafeBufferPointer<Int8>` rather than the `LevelDB.Slice`
* Check Carthage support
* SwiftCheck tests
