/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

final public class DBIterator {
    private let db_pointer: OpaquePointer

    init(query: SequenceQuery) {
        db_pointer = leveldb_create_iterator(query.db.pointer!, query.options.pointer)

        if let key = query.startKey {
            self.seek(key)
            if query.descending && self.isValid && query.db.compare(key, self.key!) == .orderedAscending {
                self.prevRow()
            }
        } else if query.descending {
            self.seekToLast()
        } else {
            self.seekToFirst()
        }
    }

    deinit {
        leveldb_iter_destroy(db_pointer)
    }

    var isValid: Bool {
        return leveldb_iter_valid(db_pointer) != 0
    }

    @discardableResult func seekToFirst() -> Bool {
        leveldb_iter_seek_to_first(db_pointer)
        return isValid
    }

    @discardableResult func seekToLast() -> Bool {
        leveldb_iter_seek_to_last(db_pointer)
        return isValid
    }

    @discardableResult func seek(_ key: Slice) -> Bool {
        key.slice { (keyBytes, keyCount) in
            leveldb_iter_seek(db_pointer, keyBytes, keyCount)
        }

        return isValid
    }

    @discardableResult func nextRow() -> Bool {
        leveldb_iter_next(db_pointer)
        return isValid
    }

    @discardableResult func prevRow() -> Bool {
        leveldb_iter_prev(db_pointer)
        return isValid
    }

    var key: Data? {
        var length: Int = 0
        let bytes = leveldb_iter_key(db_pointer, &length)
        guard length > 0 && bytes != nil else {
            return nil
        }

        return Data(bytes: bytes!, count: length)
    }

    var value: Data? {
        var length: Int = 0
        let bytes = leveldb_iter_value(db_pointer, &length)
        guard length > 0 && bytes != nil else {
            return nil
        }

        return Data(bytes: bytes!, count: length)
    }

    var error: String? {
        var error: UnsafeMutablePointer<Int8>? = nil
        leveldb_iter_get_error(db_pointer, &error)
        if error != nil {
            return String(cString: error!)
        } else {
            return nil
        }
    }

}
