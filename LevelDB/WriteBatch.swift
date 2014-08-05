/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public class WriteBatch {
    var pointer : COpaquePointer
    
    public init() {
        pointer = leveldb_writebatch_create()
    }
    
    deinit {
        leveldb_writebatch_destroy(pointer)
    }
    
    public func put(key : NSData, value : NSData?) {
        if value != nil {
            leveldb_writebatch_put(pointer, UnsafePointer<Int8>(key.bytes), UInt(key.length), UnsafePointer<Int8>(value!.bytes), UInt(value!.length))
        } else {
            leveldb_writebatch_put(pointer, UnsafePointer<Int8>(key.bytes), UInt(key.length), nil, 0)
        }
    }
    
    public func delete(key : NSData) {
        var valueLength : UInt = 0
        leveldb_writebatch_delete(pointer, UnsafePointer<Int8>(key.bytes), UInt(key.length))
    }
    
    public func clear() {
        leveldb_writebatch_clear(pointer)
    }

    // TODO: iterate - convert function pointers to blocks
}