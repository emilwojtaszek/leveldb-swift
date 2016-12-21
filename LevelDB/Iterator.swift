/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

final class Iterator {
    
    var pointer: OpaquePointer
    
    init(_ iterator: OpaquePointer) {
        pointer = iterator
    }
    
    deinit {
        leveldb_iter_destroy(pointer)
    }
        
    var isValid: Bool {
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
    
    func seek(_ key: SliceProtocol) -> Bool {
        key.slice { (keyBytes, keyCount) in
            leveldb_iter_seek(pointer, keyBytes, keyCount)
        }
        
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
    
    var key: SliceProtocol? {
        get {
            var length: Int = 0
            let bytes = leveldb_iter_key(pointer, &length)
            guard length > 0 && bytes != nil else { return nil }
            return Data(bytes: bytes!, count: length)
        }
    }
    
    var value: SliceProtocol? {
        get {
            var length: Int = 0
            let bytes = leveldb_iter_value(pointer, &length)
            guard length > 0 && bytes != nil else { return nil }
            return Data(bytes: bytes!, count: length)
        }
    }
    
    var error: String? {
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
