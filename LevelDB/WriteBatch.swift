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
        if (value) {
            leveldb_writebatch_put(pointer, ConstUnsafePointer<Int8>(key.bytes), key.length.asUnsigned(), ConstUnsafePointer<Int8>(value!.bytes), value!.length.asUnsigned())
        } else {
            leveldb_writebatch_put(pointer, ConstUnsafePointer<Int8>(key.bytes), key.length.asUnsigned(), nil, 0)
        }
    }
    
    public func delete(key : NSData) {
        var valueLength : UInt = 0
        leveldb_writebatch_delete(pointer, ConstUnsafePointer<Int8>(key.bytes), key.length.asUnsigned())
    }
    
    public func clear() {
        leveldb_writebatch_clear(pointer)
    }

    // TODO: iterate - convert function pointers to blocks
}