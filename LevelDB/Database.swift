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
            return Database(dbPointer)
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

    public init(_ dbPointer : COpaquePointer) {
        self.pointer = dbPointer;
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
    
    public func newIterator(options : ReadOptions = ReadOptions()) -> Iterator {
        let optionPointer = options.asCPointer()
        let iterator = leveldb_create_iterator(pointer, optionPointer)
        leveldb_readoptions_destroy(optionPointer)
        return Iterator(iterator)
    }
    
    public func getSnapshot() -> Snapshot {
        return Snapshot(self);
    }
}