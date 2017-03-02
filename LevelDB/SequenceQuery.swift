//
//  SequenceQuery.swift
//  LevelDB
//
//  Created by Emil Wojtaszek on 25.12.2016.
//  Copyright © 2016 codesplice. All rights reserved.
//

import Foundation

struct SequenceQuery {
    let db: Database
    let startKey: Slice?
    let endKey: Slice?
    let descending: Bool
    let options: ReadOptions

    //
    init(db: Database,
         startKey: Slice? = nil,
         endKey: Slice? = nil,
         descending: Bool = false,
         options: [ReadOption] = ReadOption.standard) {

        self.db = db
        self.startKey = startKey
        self.endKey = endKey
        self.descending = descending
        self.options = ReadOptions(options: options)
    }
}
