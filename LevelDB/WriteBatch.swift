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

    open func put(_ key: Slice, value: Data?) {
        key.slice { (keyBytes, keyCount) in
            if let value = value {
                value.slice { (valueBytes, valueCount) in
                    leveldb_writebatch_put(pointer, keyBytes, keyCount, valueBytes, valueCount)
                }
            } else {
                leveldb_writebatch_put(pointer, keyBytes, keyCount, nil, 0)
            }
        }
    }

    open func delete(_ key: Slice) {
        key.slice { (keyBytes, keyCount) in
            leveldb_writebatch_delete(pointer, keyBytes, keyCount)
        }
    }

    open func clear() {
        leveldb_writebatch_clear(pointer)
    }

    // TODO: iterate
}

public final class BatchUpdate {
    typealias UpdatesBlock = (WriteBatch) -> ()
    private let updates: UpdatesBlock

    init(updates: @escaping UpdatesBlock) {
        self.updates = updates
    }

    func perform() -> WriteBatch {
        let batch = WriteBatch()
        updates(batch)
        
        return batch
    }
}

let batch = BatchUpdate {
    $0.put("key1", value: Data())
    $0.delete("key2")
}
