/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

class Iterator {
    
    var pointer : OpaquePointer
    
    init(_ iterator : OpaquePointer) {
        pointer = iterator
    }
    
    deinit {
        leveldb_iter_destroy(pointer)
    }
        
    var isValid : Bool {
        get { return (leveldb_iter_valid(pointer) != 0) }
    }
    
    func seekToFirst() -> Bool {
        leveldb_iter_seek_to_first(pointer);
        return isValid
    }
    
    func seekToLast() -> Bool {
        leveldb_iter_seek_to_last(pointer);
        return isValid
    }
    
    func seek(_ key : Slice) -> Bool {
        leveldb_iter_seek(pointer, key.bytes, key.length)
        return isValid
    }
    
    func next() -> Bool {
        leveldb_iter_next(pointer)
        return isValid
    }
    
    func prev() -> Bool {
        leveldb_iter_prev(pointer)
        return isValid
    }
    
    var key : Slice? {
        get {
            var length : Int = 0
            let bytes = leveldb_iter_key(pointer, &length)
            if length > 0 && bytes != nil {
                return Slice(bytes: bytes!, length: length)
            } else {
                return nil
            }
        }
    }
    
    var value : Slice? {
        get {
            var length : Int = 0
            let bytes = leveldb_iter_value(pointer, &length)
            if length > 0 && bytes != nil {
                return Slice(bytes: bytes!, length: length)
            } else {
                return nil
            }
        }
    }
    
    var error : String? {
        get {
            var error: UnsafeMutablePointer<Int8>? = nil
            leveldb_iter_get_error(pointer, &error)
            if error != nil {
                return String(cString: error!)
            } else {
                return nil
            }
        }
    }


}
