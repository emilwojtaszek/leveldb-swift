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
    
    func compare(a : NSData, _ b : NSData) -> NSComparisonResult {
        let string1 = NSString(data: a, encoding: NSUTF8StringEncoding)
        let string2 = NSString(data: a, encoding: NSUTF8StringEncoding)
        return string1.compare(string2)
    }
}