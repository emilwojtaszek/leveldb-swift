/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

// TODO: DRY the crap out of this & KeySequence
public struct KeyValueSequence<Key: KeyType> : SequenceType {
    public typealias Generator = AnyGenerator<(Key, NSData?)>
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
            let currentKey = iterator.key!
            let currentValue = iterator.value
            if let key = self.endKey {
                var result = NSComparisonResult.OrderedSame
                key.withSlice { k in
                    result = self.db.compare(currentKey, k)
                }
                if !self.descending && result == .OrderedDescending
                    || self.descending && result == .OrderedAscending {
                        return nil
                }
            }
            if self.descending { iterator.prev() } else { iterator.next() }
            return (currentKey.asKey(), currentValue?.asData())
        })
    }
}