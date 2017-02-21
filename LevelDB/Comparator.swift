//
//  Comparator.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 21.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public protocol Comparator {
    var name: String { get }
    func compare(_ a: Slice, _ b: Slice) -> ComparisonResult
}

/// A Swift implementation of the default LevelDB BytewiseComparator. Note this is not actually passed
/// to LevelDB, it's only used where needed from Swift code
final class DefaultComparator: Comparator {
    var name: String { return "leveldb.BytewiseComparator" }
    func compare(_ a: Slice, _ b: Slice) -> ComparisonResult {
        // compare memory
        return a.slice { (aBytes: UnsafePointer<Int8>, aCount: Int) in
            return b.slice { (bBytes: UnsafePointer<Int8>, bCount: Int) in
                var cmp = memcmp(aBytes, bBytes, min(aCount, bCount))

                if cmp == 0 {
                    cmp = Int32(aCount - bCount)
                }

                return ComparisonResult(rawValue: (cmp < 0) ? -1 : (cmp > 0) ? 1 : 0)!
            }
        }
    }
}
