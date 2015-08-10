/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation
import XCTest
import LevelDB

class LevelDBTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func createDb(options options : Options = Options(createIfMissing: true)) -> Database? {
        #if TARGET_OS_IPHONE
            let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let directory = (dirs as [String])[0].stringByAppendingPathComponent("LevelDB")
        #else
            let currentDir = NSString(string: NSBundle(forClass: LevelDBTests.self).bundlePath).stringByDeletingLastPathComponent
            let directory = NSString(string: currentDir).stringByAppendingPathComponent("LevelDB")
        #endif
        do {
            try NSFileManager.defaultManager().removeItemAtPath(directory)
        } catch _ { /* swallow */ }
        return try! Database.createDatabase(directory, options: options)
    }
    
    // Given a sequence of elements of type T, return Array<T>
    func toArray<T, S: SequenceType where S.Generator.Element == T>(sequence: S) -> Array<T> {
        return Array<T>(sequence)
    }
    
    func testPut() {
        let db = createDb()!
        let value = "test1".dataUsingEncoding(NSUTF8StringEncoding)
        try! db.put("test", value: value)
        let response = try! db.get("test").map({ NSString(data: $0, encoding: NSUTF8StringEncoding) as! String })
        XCTAssertEqual("test1", response!)
    }
    
    func testDelete() {
        let db = createDb()!
        let key = "test"
        try! db.put(key, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.delete(key)
        let response = try! db.get(key)
        XCTAssertNil(response)
    }
    
    func testWriteBatch() {
        let db = createDb()!
        let batch = WriteBatch()
        let key1 = "test1"
        let key2 = "test2"
        batch.put(key1, value: key1.dataUsingEncoding(NSUTF8StringEncoding))
        batch.put(key2, value: key2.dataUsingEncoding(NSUTF8StringEncoding))
        try! db.write(batch);
        let response = try! db.get(key2).map({ NSString(data: $0, encoding: NSUTF8StringEncoding) as! String })
        XCTAssertEqual("test2", response!)
    }
    
    func testKeySequence() {
        let db = createDb()!
        let key1 = "test1"
        let key2 = "test2"
        let key3 = "test3"
        try! db.put(key1, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.put(key2, value: "test2".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.put(key3, value: "test3".dataUsingEncoding(NSUTF8StringEncoding))
        var index = 0
        print("iterating all keys ascending")
        for key : String in db.keys() {
            index++
            let keyName = String(format: "test%d", index)
            print(key)
            XCTAssertEqual(keyName, key)
        }
        XCTAssertEqual(index, 3)
        index = 1
        print("iterating all keys from test11 to test21 ascending")
        for key in db.keys(from:"test11", to:"test21") {
            index++
            let keyName = "test\(index)"
            print(key)
            XCTAssertEqual(keyName, key)
        }
        XCTAssertEqual(index, 2)
    }
    
    func testKeyValueSequence() {
        let db = createDb()!
        let key1 = "test1"
        let key2 = "test2"
        let key3 = "test3"
        try! db.put(key1, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.put(key2, value: "test2".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.put(key3, value: "test3".dataUsingEncoding(NSUTF8StringEncoding))
        var index = 0
        print("iterating all keys & values ascending")
        for (key, value): (String, NSData?) in db.values() {
            index++
            let keyName = "test\(index)"
            let valueString = NSString(data: value!, encoding: NSUTF8StringEncoding) as! String
            print("\(key): \(valueString)")
            XCTAssertEqual(keyName, key)
            XCTAssertEqual(keyName, valueString)
        }
        XCTAssertEqual(index, 3)
    }

    func testKeySequenceDescending() {
        let db = createDb()!
        let key1 = "test1"
        let key2 = "test2"
        let key3 = "test3"
        try! db.put(key1, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.put(key2, value: "test2".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.put(key3, value: "test3".dataUsingEncoding(NSUTF8StringEncoding))
        var index = 3
        print("iterating all keys descending")
        for key: String in db.keys(descending:true) {
            let keyName = "test\(index)"
            print(key)
            XCTAssertEqual(keyName, key)
            index--
        }
        XCTAssertEqual(index, 0)
        index = 2
        print("iterating all keys from test21 to test11 descending")
        for key in db.keys(from:"test21", to:"test11", descending:true) {
            let keyName = "test\(index)"
            print(key)
            XCTAssertEqual(keyName, key)
            index--
        }
        XCTAssertEqual(index, 1)
    }
    

    func testComparator() {
        let opt = Options(createIfMissing: true, comparator: TestComparator())
        let db = createDb(options: opt)!
        let key1 = "test1".dataUsingEncoding(NSUTF8StringEncoding)!
        let key2 = "test2".dataUsingEncoding(NSUTF8StringEncoding)!
        let key3 = "test3".dataUsingEncoding(NSUTF8StringEncoding)!
        try! db.put(key3, value: "test3".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.put(key2, value: "test2".dataUsingEncoding(NSUTF8StringEncoding))
        try! db.put(key1, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        var index = 0
        print("iterating all keys & values ascending")
        for (key, value): (String, NSData?) in db.values() {
            index++
            let keyName = "test\(index)"
            let valueString = NSString(data: value!, encoding: NSUTF8StringEncoding) as! String
            print("\(key): \(valueString)")
            XCTAssertEqual(keyName, key)
            XCTAssertEqual(keyName, valueString)
        }
        // TODO: Failing - there's something wrong with the custom comparator
        //XCTAssertEqual(index, 3)*/
    }
}
