/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

// TODO: DRY the crap out of this & KeySequence
public struct KeyValueSequence<Key: SliceProtocol>: Sequence {
    public typealias Iterator = AnyIterator<(Data, Data?)>
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
            let currentKey = iterator.key!
            let currentValue = iterator.value
            if let key = self.endKey {
                var result = ComparisonResult.orderedSame
                result = self.db.compare(currentKey, key)
                if !self.descending && result == .orderedDescending
                    || self.descending && result == .orderedAscending {
                        return nil
                }
            }
            if self.descending { _ = iterator.prev() } else { _ = iterator.next() }
            return (currentKey.data(), currentValue?.data())
        })
    }
}
