/*
 * Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
 *
 * Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
 */

import Foundation

/// @brief A LevelDB database instance.
/// @discussion There should only be one instance created for a specific directory.
/// Use the class factory method 'createDatabase' to create a new instance.
public class Database {
    var pointer : COpaquePointer;
    let comparator : Comparator;
    
    public class var majorVersion : Int {
        get { return Int(leveldb_major_version()) }
    }
    public class var minorVersion : Int {
        get { return Int(leveldb_minor_version()) }
    }
    
    public class func createDatabase(directory : String, options : Options = Options()) -> Database? {
        let cdir = (directory as NSString).UTF8String
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>.null()
        let dbPointer = leveldb_open(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if dbPointer == nil {
            NSLog("%@", String.fromCString(error)!)
            return nil;
        } else {
            return Database(dbPointer, comparator: options.comparator)
        }
    }
    
    public class func destroyDatabase(directory : String, options : Options = Options()) {
        let cdir = (directory as NSString).UTF8String
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>.null()
        leveldb_destroy_db(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if error != nil {
            NSLog("%@", String.fromCString(error)!)
        }
    }

    public class func repairDatabase(directory : String, options : Options = Options()) {
        let cdir = (directory as NSString).UTF8String
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>.null()
        leveldb_repair_db(optionPtr, cdir, &error)
        leveldb_options_destroy(optionPtr)
        if error != nil  {
            NSLog("%@", String.fromCString(error)!)
        }
    }

    init(_ dbPointer : COpaquePointer, comparator : Comparator? = nil) {
        self.pointer = dbPointer;
        self.comparator = (comparator != nil) ? comparator! : DefaultComparator()
    }

    deinit {
        if pointer != nil {
            leveldb_close(pointer)
        }
    }
    
    public func get(key : NSData, options : ReadOptions = ReadOptions()) -> NSData? {
        let optionPtr = options.asCPointer()
        var valueLength : UInt = 0
        var error = UnsafeMutablePointer<Int8>.null()
        let value = leveldb_get(pointer, optionPtr, UnsafePointer<Int8>(key.bytes), UInt(key.length), &valueLength, &error)
        leveldb_readoptions_destroy(optionPtr)
        if error != nil {
            NSLog("%@", String.fromCString(error)!)
            return nil
        } else if (valueLength == 0) {
            return nil
        } else {
            return NSData(bytesNoCopy: value, length: Int(valueLength), freeWhenDone:true)
        }
    }
    
    public func put(key : NSData, value : NSData?, options : WriteOptions = WriteOptions()) {
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>.null()
        if value != nil {
            leveldb_put(pointer, optionPtr, UnsafePointer<Int8>(key.bytes), UInt(key.length), UnsafePointer<Int8>(value!.bytes), UInt(value!.length), &error)
        } else {
            leveldb_put(pointer, optionPtr, UnsafePointer<Int8>(key.bytes), UInt(key.length), nil, 0, &error)
        }
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            NSLog("%@", String.fromCString(error)!)
        }
    }
    
    public func delete(key : NSData, options : WriteOptions = WriteOptions()) {
        let optionPtr = options.asCPointer()
        var valueLength : UInt = 0
        var error = UnsafeMutablePointer<Int8>.null()
        leveldb_delete(pointer, optionPtr, UnsafePointer<Int8>(key.bytes), UInt(key.length), &error)
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            NSLog("%@", String.fromCString(error)!)
        }
    }
    
    public func write(batch : WriteBatch, options : WriteOptions = WriteOptions()) {
        let optionPtr = options.asCPointer()
        var error = UnsafeMutablePointer<Int8>.null()
        leveldb_write(pointer, optionPtr, batch.pointer, &error)
        leveldb_writeoptions_destroy(optionPtr)
        if error != nil {
            NSLog("%@", String.fromCString(error)!)
        }        
    }
    
    func newIterator(options : ReadOptions = ReadOptions()) -> Iterator {
        let optionPointer = options.asCPointer()
        let iterator = leveldb_create_iterator(pointer, optionPointer)
        leveldb_readoptions_destroy(optionPointer)
        return Iterator(iterator)
    }
    
    public func keys(from: NSData? = nil, to : NSData? = nil, descending : Bool = false) -> KeySequence {
        return KeySequence(db: self, startKey: from, endKey: to, descending: descending)
    }
    
    public func values(from: NSData? = nil, to : NSData? = nil, descending : Bool = false) -> KeyValueSequence {
        return KeyValueSequence(db: self, startKey: from, endKey: to, descending: descending)
    }

    public func getSnapshot() -> Snapshot {
        return Snapshot(self);
    }
    
    /// A Swift implementation of the default LevelDB BytewiseComparator. Note this is not actually passed
    /// to LevelDB, it's only used where needed from Swift code
    class DefaultComparator : Comparator {
        var name : String { get { return "leveldb.BytewiseComparator" } }
        func compare(a: NSData, _ b: NSData) -> NSComparisonResult {
            var r = Int(memcmp(a.bytes, b.bytes, min(UInt(a.length), UInt(b.length))))
            if (r == 0) { r = a.length - b.length }
            return NSComparisonResult.fromRaw((r < 0) ? -1 : (r > 0) ? 1 : 0)!
        }
    }
}