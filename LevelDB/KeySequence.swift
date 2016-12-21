/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public struct KeySequence<Key: SliceProtocol>: Sequence {
    public typealias Iterator = AnyIterator<Data>
    let db: Database
    let startKey: Key?
    let endKey: Key?
    let descending: Bool
    
    init(db: Database, startKey: Key? = nil, endKey: Key? = nil, descending: Bool = false) {
        self.db = db
        self.startKey = startKey
        self.endKey = endKey
        self.descending = descending
    }
    
    public func makeIterator() -> Iterator {
        let iterator = db.newIterator()
        if let key = startKey {
            _ = iterator.seek(key)
            if descending && iterator.isValid && db.compare(key, iterator.key!) == .orderedAscending {
                _ = iterator.prev()
            }
        } else if descending {
            _ = iterator.seekToLast()
        } else {
            _ = iterator.seekToFirst()
        }

        return AnyIterator({
            if !iterator.isValid {
                return nil
            }
            let currentSlice = iterator.key!
            let currentKey = currentSlice.data()
            if let key = self.endKey {
                var result = ComparisonResult.orderedSame
                result = self.db.compare(currentSlice, key)
                if !self.descending && result == .orderedDescending
                    || self.descending && result == .orderedAscending {
                        return nil
                }
            }
            if self.descending { _ = iterator.prev() } else { _ = iterator.next() }
            return currentKey
        })
    }
}
