/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

open class WriteBatch {
    let pointer: OpaquePointer
    
    public init() {
        pointer = leveldb_writebatch_create()
    }
    
    deinit {
        leveldb_writebatch_destroy(pointer)
    }
    
    open func put(_ key: KeyType, value: Data?) {
        key.withSlice { k in
            if let value = value.map({ Slice(data: $0) }) {
                leveldb_writebatch_put(pointer, k.bytes, k.length, value.bytes, value.length)
            } else {
                leveldb_writebatch_put(pointer, k.bytes, k.length, nil, 0)
            }
        }
    }
    
    open func delete(_ key: KeyType) {
        key.withSlice { k in
            leveldb_writebatch_delete(pointer, k.bytes, k.length)
        }
    }
    
    open func clear() {
        leveldb_writebatch_clear(pointer)
    }

    // TODO: iterate
}
