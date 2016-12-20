/*
 * Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
 *
 * Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
 */

import Foundation

public enum LevelDBError: Error {
    case openError(message: String)
    case destroyError(message: String)
    case repairError(message: String)
    case readError(message: String)
    case writeError(message: String)
}

/** **A LevelDB database instance**
There should only be one instance created for a specific directory.
*/
public final class Database {
    var pointer : OpaquePointer?;
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
    public class func createDatabase(_ directory : String, options : Options = Options()) throws -> Database {
        let cdir = (directory as NSString).utf8String
        let optionPtr = options.asCPointer()
        var error: UnsafeMutablePointer<Int8>? = nil
        let dbPointer = leveldb_open(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if dbPointer == nil {
            if let error = error {
                throw LevelDBError.openError(message: String(cString: error))
            } else {
                throw LevelDBError.openError(message: "Undefined error")
            }
        } else {
            return Database(dbPointer!, comparator: options.comparator)
        }
    }
    
    public class func destroyDatabase(_ directory : String, options : Options = Options()) throws {
        let cdir = (directory as NSString).utf8String
        let optionPtr = options.asCPointer()
        var error: UnsafeMutablePointer<Int8>? = nil
        leveldb_destroy_db(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.destroyError(message: String(cString: error!))
        }
    }

    public class func repairDatabase(_ directory : String, options : Options = Options()) throws {
        let cdir = (directory as NSString).utf8String
        let optionPtr = options.asCPointer()
        var error: UnsafeMutablePointer<Int8>? = nil
        leveldb_repair_db(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if error != nil  {
            throw LevelDBError.repairError(message: String(cString: error!))
        }
    }

    init(_ dbPointer : OpaquePointer, comparator : Comparator? = nil) {
        self.pointer = dbPointer
        self.comparator = comparator
    }

    deinit {
        if pointer != nil {
            leveldb_close(pointer)
        }
    }
    
    public func get(_ key: KeyType, options: ReadOptions = ReadOptions()) throws -> Data? {
        let optionPtr = options.asCPointer()
        var valueLength = 0
        var error: UnsafeMutablePointer<Int8>? = nil
        var value: UnsafeMutablePointer<Int8>? = nil
        key.withSlice { k in
            value = leveldb_get(pointer, optionPtr, k.bytes, k.length, &valueLength, &error)
        }
        leveldb_readoptions_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.readError(message: String(cString: error!))
        } else if (valueLength == 0) {
            return nil
        } else {
            return Data(bytes: value!, count: valueLength)
        }
    }
    
    public func put(_ key: KeyType, value: Data?, options: WriteOptions = WriteOptions()) throws {
        let optionPtr = options.asCPointer()
        var error: UnsafeMutablePointer<Int8>? = nil
        key.withSlice { k in
            if let value = value {
                leveldb_put(pointer, optionPtr, k.bytes, k.length, (value as NSData).bytes.bindMemory(to: Int8.self, capacity: value.count), value.count, &error)
            } else {
                leveldb_put(pointer, optionPtr, k.bytes, k.length, nil, 0, &error)
            }
        }
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }
    
    public func delete(_ key: KeyType, options: WriteOptions = WriteOptions()) throws {
        let optionPtr = options.asCPointer()
        var error: UnsafeMutablePointer<Int8>? = nil
        key.withSlice { k in
            leveldb_delete(pointer, optionPtr, k.bytes, k.length, &error)
        }
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }
    
    public func write(_ batch : WriteBatch, options : WriteOptions = WriteOptions()) throws {
        let optionPtr = options.asCPointer()
        var error: UnsafeMutablePointer<Int8>? = nil
        leveldb_write(pointer, optionPtr, batch.pointer, &error)
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }
    
    func newIterator(_ options : ReadOptions = ReadOptions()) -> Iterator {
        let optionPointer = options.asCPointer()
        let iterator = leveldb_create_iterator(pointer, optionPointer)
        leveldb_readoptions_destroy(optionPointer)
        return Iterator(iterator!)
    }
    
    public func keys() -> KeySequence<String> {
        return KeySequence<String>(db: self, startKey: nil, endKey: nil, descending: false)
    }
    
    public func keys<Key: KeyType>(from: Key? = nil, to: Key? = nil, descending: Bool = false) -> KeySequence<Key> {
        return KeySequence<Key>(db: self, startKey: from, endKey: to, descending: descending)
    }
    
    public func values() -> KeyValueSequence<String> {
        return KeyValueSequence<String>(db: self, startKey: nil, endKey: nil, descending: false)
    }

    public func values<Key: KeyType>(from: Key? = nil, to: Key? = nil, descending: Bool = false) -> KeyValueSequence<Key> {
        return KeyValueSequence<Key>(db: self, startKey: from, endKey: to, descending: descending)
    }

    public func getSnapshot() -> Snapshot {
        return Snapshot(self);
    }
    
    /// Internal compare designed to be used for key bounds checking during iteration.
    func compare(_ a: Slice, _ b: Slice) -> ComparisonResult {
        if let comparator = self.comparator {
            return comparator.compare(a, b)
        } else {
            var r = Int(memcmp(a.bytes, b.bytes, min(a.length, b.length)))
            if (r == 0) { r = a.length - b.length }
            return ComparisonResult(rawValue: (r < 0) ? -1 : (r > 0) ? 1 : 0)!
        }
    }
    
    /// A Swift implementation of the default LevelDB BytewiseComparator. Note this is not actually passed
    /// to LevelDB, it's only used where needed from Swift code
    class DefaultComparator : Comparator {
        var name : String { get { return "leveldb.BytewiseComparator" } }
        func compare(_ a: Slice, _ b: Slice) -> ComparisonResult {
            var r = Int(memcmp(a.bytes, b.bytes, min(a.length, b.length)))
            if (r == 0) { r = a.length - b.length }
            return ComparisonResult(rawValue: (r < 0) ? -1 : (r > 0) ? 1 : 0)!
        }
    }
}
