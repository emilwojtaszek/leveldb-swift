/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public class Iterator {
    var pointer : COpaquePointer
    
    init(_ iterator : COpaquePointer) {
        pointer = iterator
    }
    
    deinit {
        leveldb_iter_destroy(pointer)
    }
    
    public var isValid : Bool {
        get { return (leveldb_iter_valid(pointer) != 0) }
    }
    
    public func seekToFirst() -> Bool {
        leveldb_iter_seek_to_first(pointer);
        return isValid
    }
    
    public func seekToLast() -> Bool {
        leveldb_iter_seek_to_last(pointer);
        return isValid
    }
    
    public func seek(key : NSData) -> Bool {
        leveldb_iter_seek(pointer, ConstUnsafePointer<Int8>(key.bytes), key.length.asUnsigned())
        return isValid
    }
    
    public func next() -> Bool {
        leveldb_iter_next(pointer)
        return isValid
    }
    
    public func prev() -> Bool {
        leveldb_iter_prev(pointer)
        return isValid
    }
    
    public var key : NSData? {
        get {
            var length : UInt = 0
            let bytes = leveldb_iter_key(pointer, &length)
            if length > 0 && bytes {
                return NSData(bytes: bytes, length: length.asSigned())
            } else {
                return nil
            }
        }
    }
    
    public var value : NSData? {
        get {
            var length : UInt = 0
            let bytes = leveldb_iter_value(pointer, &length)
            if length > 0 && bytes {
                return NSData(bytes: bytes, length: length.asSigned())
            } else {
                return nil
            }
        }
    }
    
    public var error : String? {
        get {
            var error = UnsafePointer<Int8>.null()
            leveldb_iter_get_error(pointer, &error)
            if error {
                return String.fromCString(error)!
            } else {
                return nil
            }
        }
    }


}