/*
 * Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
 *
 * Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
 */

import Foundation

public enum LevelDBError: ErrorType {
    case OpenError(message: String)
    case DestroyError(message: String)
    case RepairError(message: String)
    case ReadError(message: String)
    case WriteError(message: String)
}

/** **A LevelDB database instance**
There should only be one instance created for a specific directory.
*/
public class Database {
    var pointer : COpaquePointer;
    let comparator : Comparator?;
    
    public class var majorVersion : Int {
        get { return Int(leveldb_major_version()) }
    }
    public class var minorVersion : Int {
        get { return Int(leveldb_minor_version()) }
    } 
    
    /**
    :param directory  The directory for the database. This should already exist?
    */
    public class func createDatabase(directory : String, options : Options = Options()) throws -> Database {
        let cdir = (directory as NSString).UTF8String
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>()
        let dbPointer = leveldb_open(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if dbPointer == nil {
            throw LevelDBError.OpenError(message: String.fromCString(error)!)
        } else {
            return Database(dbPointer, comparator: options.comparator)
        }
    }
    
    public class func destroyDatabase(directory : String, options : Options = Options()) throws {
        let cdir = (directory as NSString).UTF8String
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>()
        leveldb_destroy_db(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.DestroyError(message: String.fromCString(error)!)
        }
    }

    public class func repairDatabase(directory : String, options : Options = Options()) throws {
        let cdir = (directory as NSString).UTF8String
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>()
        leveldb_repair_db(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if error != nil  {
            throw LevelDBError.RepairError(message: String.fromCString(error)!)
        }
    }

    init(_ dbPointer : COpaquePointer, comparator : Comparator? = nil) {
        self.pointer = dbPointer
        self.comparator = comparator
    }

    deinit {
        if pointer != nil {
            leveldb_close(pointer)
        }
    }
    
    public func get(key: KeyType, options: ReadOptions = ReadOptions()) throws -> NSData? {
        let optionPtr = options.asCPointer()
        var valueLength = 0
        var error = UnsafeMutablePointer<Int8>()
        var value: UnsafeMutablePointer<Int8> = nil
        key.withSlice { k in
            value = leveldb_get(pointer, optionPtr, k.bytes, k.length, &valueLength, &error)
        }
        leveldb_readoptions_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.ReadError(message: String.fromCString(error)!)
        } else if (valueLength == 0) {
            return nil
        } else {
            return NSData(bytes: value, length: valueLength)
        }
    }
    
    public func put(key: KeyType, value: NSData?, options: WriteOptions = WriteOptions()) throws {
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>()
        key.withSlice { k in
            if let value = value {
                leveldb_put(pointer, optionPtr, k.bytes, k.length, UnsafePointer<Int8>(value.bytes), value.length, &error)
            } else {
                leveldb_put(pointer, optionPtr, k.bytes, k.length, nil, 0, &error)
            }
        }
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.WriteError(message: String.fromCString(error)!)
        }
    }
    
    public func delete(key: KeyType, options: WriteOptions = WriteOptions()) throws {
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>()
        key.withSlice { k in
            leveldb_delete(pointer, optionPtr, k.bytes, k.length, &error)
        }
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.WriteError(message: String.fromCString(error)!)
        }
    }
    
    public func write(batch : WriteBatch, options : WriteOptions = WriteOptions()) throws {
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>()
        leveldb_write(pointer, optionPtr, batch.pointer, &error)
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.WriteError(message: String.fromCString(error)!)
        }
    }
    
    func newIterator(options : ReadOptions = ReadOptions()) -> Iterator {
        let optionPointer = options.asCPointer()
        let iterator = leveldb_create_iterator(pointer, optionPointer)
        leveldb_readoptions_destroy(optionPointer)
        return Iterator(iterator)
    }
    
    public func keys<Key: KeyType>(from from: Key? = nil, to: Key? = nil, descending: Bool = false) -> KeySequence<Key> {
        return KeySequence<Key>(db: self, startKey: from, endKey: to, descending: descending)
    }
    
    public func values<Key: KeyType>(from from: Key? = nil, to: Key? = nil, descending: Bool = false) -> KeyValueSequence<Key> {
        return KeyValueSequence<Key>(db: self, startKey: from, endKey: to, descending: descending)
    }

    public func getSnapshot() -> Snapshot {
        return Snapshot(self);
    }
    
    /// Internal compare designed to be used for key bounds checking during iteration.
    func compare(a: Slice, _ b: Slice) -> NSComparisonResult {
        if let comparator = self.comparator {
            return comparator.compare(a, b)
        } else {
            var r = Int(memcmp(a.bytes, b.bytes, min(a.length, b.length)))
            if (r == 0) { r = a.length - b.length }
            return NSComparisonResult(rawValue: (r < 0) ? -1 : (r > 0) ? 1 : 0)!
        }
    }
    
    /// A Swift implementation of the default LevelDB BytewiseComparator. Note this is not actually passed
    /// to LevelDB, it's only used where needed from Swift code
    class DefaultComparator : Comparator {
        var name : String { get { return "leveldb.BytewiseComparator" } }
        func compare(a: Slice, _ b: Slice) -> NSComparisonResult {
            var r = Int(memcmp(a.bytes, b.bytes, min(a.length, b.length)))
            if (r == 0) { r = a.length - b.length }
            return NSComparisonResult(rawValue: (r < 0) ? -1 : (r > 0) ? 1 : 0)!
        }
    }
}