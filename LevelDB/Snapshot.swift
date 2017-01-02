/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

open class Snapshot {
    var pointer: OpaquePointer?
    var db: Database

    init(_ db: Database) {
        self.db = db
        pointer = leveldb_create_snapshot(db.pointer)
    }

    deinit {
        if pointer != nil {
            leveldb_release_snapshot(db.pointer, pointer)
        }
    }
}
