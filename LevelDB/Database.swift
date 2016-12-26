/*
 * Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
 *
 * Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
 */

import Foundation

public enum LevelDBError: Error {
    case undefinedError
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
    var pointer: OpaquePointer?
    let comparator: Comparator
    
    public class var majorVersion: Int {
        get { return Int(leveldb_major_version()) }
    }
    public class var minorVersion: Int {
        get { return Int(leveldb_minor_version()) }
    } 
    
    /**
    :param directory  The directory for the database. This should already exist?
    */
    public class func create(_ directory: String, options: FileOptions = FileOptions()) throws -> Database {
        let cdir = (directory as NSString).utf8String
        var error: UnsafeMutablePointer<Int8>? = nil

        // open database
        if let dbPointer = leveldb_open(options.pointer(), cdir, &error) {
            return Database(dbPointer, comparator: options.comparator)
        } else {
            if let error = error {
                throw LevelDBError.openError(message: String(cString: error))
            }
            throw LevelDBError.undefinedError
        }
    }
    
    public class func destroy(_ directory: String, options: FileOptions = FileOptions()) throws {
        let cdir = (directory as NSString).utf8String
        var error: UnsafeMutablePointer<Int8>? = nil

        // close database
        leveldb_destroy_db(options.pointer(), cdir, &error)
        if let error = error {
            throw LevelDBError.destroyError(message: String(cString: error))
        }
    }

    public class func repair(_ directory: String, options: FileOptions = FileOptions()) throws {
        let cdir = (directory as NSString).utf8String
        var error: UnsafeMutablePointer<Int8>? = nil
        
        // rapair
        leveldb_repair_db(options.pointer(), cdir, &error)
        if let error = error {
            throw LevelDBError.repairError(message: String(cString: error))
        }
    }

    init(_ dbPointer: OpaquePointer, comparator: Comparator = DefaultComparator()) {
        self.pointer = dbPointer
        self.comparator = comparator
    }

    deinit {
        if pointer != nil {
            leveldb_close(pointer)
        }
    }
    
    public func get(_ key: Slice, options: ReadOptions = ReadOptions()) throws -> Data? {
        var valueLength = 0
        var error: UnsafeMutablePointer<Int8>? = nil
        var value: UnsafeMutablePointer<Int8>? = nil

        key.slice { (keyBytes, keyCount) in
            value = leveldb_get(pointer, options.pointer(), keyBytes, keyCount, &valueLength, &error)
        }
        
        // throw if error
        guard error == nil else {
            throw LevelDBError.readError(message: String(cString: error!))
        }
        
        // check fetch value lenght
        guard valueLength > 0 else {
            return nil
        }

        // create data
        return Data(bytes: value!, count: valueLength)
    }
    
    public func put(_ key: Slice, value: Data?, options: WriteOptions = WriteOptions()) throws {
        var error: UnsafeMutablePointer<Int8>? = nil

        //
        key.slice { (keyBytes, keyCount) in
            if let value = value {
                value.withUnsafeBytes {
                    leveldb_put(pointer, options.pointer(), keyBytes, keyCount, $0, value.count, &error)
                }
            } else {
                leveldb_put(pointer, options.pointer(), keyBytes, keyCount, nil, 0, &error)
            }
        }

        // throw on error
        guard error == nil else {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }
    
    public func delete(_ key: Slice, options: WriteOptions = WriteOptions()) throws {
        var error: UnsafeMutablePointer<Int8>? = nil
        
        //
        key.slice { (keyBytes, keyCount) in
            leveldb_delete(pointer, options.pointer(), keyBytes, keyCount, &error)
        }
        
        // throw on error
        guard error == nil else {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }
    
    public func write(_ batch: WriteBatch, options: WriteOptions = WriteOptions()) throws {
        var error: UnsafeMutablePointer<Int8>? = nil
        
        //
        leveldb_write(pointer, options.pointer(), batch.pointer, &error)
        if error != nil {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }
    
//    public func keys() -> KeySequence<String> {
//        return KeySequence<String>(db: self, startKey: nil, endKey: nil, descending: false)
//    }
    
//    public func keys<Key: Slice>(from: Key? = nil, to: Key? = nil, descending: Bool = false) -> KeySequence<Key> {
//        return KeySequence<Key>(db: self, startKey: from, endKey: to, descending: descending)
//    }

    public func keys(from: Data? = nil, to: Data? = nil, descending: Bool = false) -> KeySequence {
        let query = SequenceQuery(db: self, startKey: from, endKey: to, descending: descending)
        return KeySequence(query: query)
    }

//    public func values() -> KeyValueSequence<String> {
//        return KeyValueSequence<String>(db: self, startKey: nil, endKey: nil, descending: false)
//    }

//    public func values<Key: Slice>(from: Key? = nil, to: Key? = nil, descending: Bool = false) -> KeyValueSequence<Key> {
//        return KeyValueSequence<Key>(db: self, startKey: from, endKey: to, descending: descending)
//    }
    
    public func values(from: Data? = nil, to: Data? = nil, descending: Bool = false) -> KeyValueSequence {
        let query = SequenceQuery(db: self, startKey: from, endKey: to, descending: descending)
        return KeyValueSequence(query: query)
    }

    public func getSnapshot() -> Snapshot {
        return Snapshot(self);
    }
    
    /// Internal compare designed to be used for key bounds checking during iteration.
    func compare(_ a: Slice, _ b: Slice) -> ComparisonResult {
        return comparator.compare(a, b)
    }
}
