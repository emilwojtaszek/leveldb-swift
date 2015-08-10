/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public struct KeySequence<Key: KeyType> : SequenceType {
    public typealias Generator = AnyGenerator<Key>
    let db : Database
    let startKey : Key?
    let endKey : Key?
    let descending : Bool
    
    init(db : Database, startKey : Key? = nil, endKey : Key? = nil, descending : Bool = false) {
        self.db = db
        self.startKey = startKey
        self.endKey = endKey
        self.descending = descending
    }
    
    public func generate() -> Generator {
        let iterator = db.newIterator()
        if let key = startKey {
            key.withSlice { k in
                iterator.seek(k)
                if descending && iterator.isValid && db.compare(k, iterator.key!) == .OrderedAscending {
                    iterator.prev()
                }
            }
        } else if descending {
            iterator.seekToLast()
        } else {
            iterator.seekToFirst()
        }
        return anyGenerator({
            if !iterator.isValid {
                return nil
            }
            let currentSlice = iterator.key!
            let currentKey = Key(bytes: currentSlice.bytes, length: currentSlice.length)
            if let key = self.endKey {
                var result = NSComparisonResult.OrderedSame
                key.withSlice { k in
                    result = self.db.compare(currentSlice, k)
                }
                if !self.descending && result == .OrderedDescending
                    || self.descending && result == .OrderedAscending {
                        return nil
                }
            }
            if self.descending { iterator.prev() } else { iterator.next() }
            return currentKey
        })
    }
}