/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public struct KeySequence : SequenceType {
    public typealias Generator = GeneratorOf<NSData>
    let db : Database
    let startKey : NSData?
    let endKey : NSData?
    let descending : Bool
    
    init(db : Database, startKey : NSData? = nil, endKey : NSData? = nil, descending : Bool = false) {
        self.db = db
        self.startKey = startKey
        self.endKey = endKey
        self.descending = descending
    }
    
    public func generate() -> Generator {
        let iterator = db.newIterator()
        if let key = startKey {
            iterator.seek(key)
            if descending && iterator.isValid && db.comparator.compare(key, iterator.key!) == NSComparisonResult.OrderedAscending {
                iterator.prev()
            }
        } else if descending {
            iterator.seekToLast()
        } else {
            iterator.seekToFirst()
        }
        return GeneratorOf<NSData>({ () -> NSData? in
            if !iterator.isValid {
                return nil
            }
            let currentKey = iterator.key!
            if self.endKey.hasValue {
                let result = self.db.comparator.compare(currentKey, self.endKey!)
                if !self.descending && result == NSComparisonResult.OrderedDescending
                    || self.descending && result == NSComparisonResult.OrderedAscending {
                    return nil
                }
            }
            if self.descending { iterator.prev() } else { iterator.next() }
            return currentKey
        })
    }
}