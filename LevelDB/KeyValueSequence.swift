/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public struct KeyValueSequence: Sequence {
    public typealias Iterator = AnyIterator<(Data, Data?)>
    private let query: SequenceQuery

    init(query: SequenceQuery) {
        self.query = query
    }

    public func makeIterator() -> Iterator {
        let iterator = DBIterator(query: self.query)

        return AnyIterator({
            guard iterator.isValid else {
                return nil
            }

            let currentKey = iterator.key!
            let currentValue = iterator.value

            if let key = self.query.endKey {
                let result = self.query.db.compare(currentKey, key)
                if !self.query.descending && result == .orderedDescending
                    || self.query.descending && result == .orderedAscending {
                        return nil
                }
            }

            if self.query.descending {
                _ = iterator.prevRow()
            } else {
                _ = iterator.nextRow()
            }

            return (currentKey.data(), currentValue?.data())
        })
    }
}
