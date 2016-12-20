/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation
import LevelDB

class TestComparator : LevelDB.Comparator {
    var name : String {
        get {
            return "test"
        }
    }
    
    func compare(_ a : LevelDB.Slice, _ b : LevelDB.Slice) -> ComparisonResult {
        let string1 = String(bytes: a.bytes, count: a.length)
        let string2 = String(bytes: b.bytes, count: b.length)
        return string1.compare(string2)
    }
}
