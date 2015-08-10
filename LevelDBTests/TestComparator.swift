/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation
import LevelDB

class TestComparator : Comparator {
    var name : String {
    get {
        return "test"
    }
    }
    
    func compare(a : LevelDB.Slice, _ b : LevelDB.Slice) -> NSComparisonResult {
        let string1 = String(bytes: a.bytes, length: a.length)
        let string2 = String(bytes: b.bytes, length: b.length)
        return string1.compare(string2)
    }
}