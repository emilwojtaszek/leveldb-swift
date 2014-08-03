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
    
    func createDb(options : Options = Options(createIfMissing: true)) -> Database? {
        #if TARGET_OS_IPHONE
            let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let directory = (dirs as [String])[0].stringByAppendingPathComponent("LevelDB")
        #else
            let currentDir = NSBundle(forClass: LevelDBTests.self).bundlePath.stringByDeletingLastPathComponent
            let directory = currentDir.stringByAppendingPathComponent("LevelDB")
        #endif
        NSFileManager.defaultManager().removeItemAtPath(directory, error: nil)
        return Database.createDatabase(directory, options: options)
    }
    
    func testPut() {
        let db = createDb()!
        let key = "test".dataUsingEncoding(NSUTF8StringEncoding)!
        db.put(key, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        let response = db.get(key)
        XCTAssertEqual("test1", NSString(data: response, encoding: NSUTF8StringEncoding))
    }
    
    func testDelete() {
        let db = createDb()!
       let key = "test".dataUsingEncoding(NSUTF8StringEncoding)!
        db.put(key, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        db.delete(key)
        let response = db.get(key)
        XCTAssertNil(response)
    }
    
    func testWriteBatch() {
        let db = createDb()!
        let batch = WriteBatch()
        let key1 = "test1".dataUsingEncoding(NSUTF8StringEncoding)!
        let key2 = "test2".dataUsingEncoding(NSUTF8StringEncoding)!
        batch.put(key1, value: key1)
        batch.put(key2, value: key2)
        db.write(batch);
        let response = db.get(key2)
        XCTAssertEqual("test2", NSString(data: response, encoding: NSUTF8StringEncoding))
    }
    
    func testIterate() {
        let db = createDb()!
        let key1 = "test1".dataUsingEncoding(NSUTF8StringEncoding)!
        let key2 = "test2".dataUsingEncoding(NSUTF8StringEncoding)!
        let key3 = "test3".dataUsingEncoding(NSUTF8StringEncoding)!
        db.put(key1, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        db.put(key2, value: "test2".dataUsingEncoding(NSUTF8StringEncoding))
        db.put(key3, value: "test3".dataUsingEncoding(NSUTF8StringEncoding))
        let iterator = db.newIterator()
        iterator.seekToFirst()
        XCTAssertEqual("test1", NSString(data: iterator.key, encoding: NSUTF8StringEncoding))
        XCTAssertEqual("test1", NSString(data: iterator.value, encoding: NSUTF8StringEncoding))
        while (iterator.next()) {
            XCTAssertEqual(NSString(data: iterator.key, encoding: NSUTF8StringEncoding), NSString(data: iterator.value, encoding: NSUTF8StringEncoding))
        }
    }
    
    func testComparator() {
        let opt = Options(createIfMissing: true, comparator: TestComparator())
        let db = createDb(options: opt)!
        let key1 = "test1".dataUsingEncoding(NSUTF8StringEncoding)!
        let key2 = "test2".dataUsingEncoding(NSUTF8StringEncoding)!
        let key3 = "test3".dataUsingEncoding(NSUTF8StringEncoding)!
        db.put(key3, value: "test3".dataUsingEncoding(NSUTF8StringEncoding))
        db.put(key2, value: "test2".dataUsingEncoding(NSUTF8StringEncoding))
        db.put(key1, value: "test1".dataUsingEncoding(NSUTF8StringEncoding))
        let iterator = db.newIterator()
        iterator.seekToFirst()
        XCTAssertEqual("test1", NSString(data: iterator.key, encoding: NSUTF8StringEncoding))
        XCTAssertEqual("test1", NSString(data: iterator.value, encoding: NSUTF8StringEncoding))
        while (iterator.next()) {
            XCTAssertEqual(NSString(data: iterator.key, encoding: NSUTF8StringEncoding), NSString(data: iterator.value, encoding: NSUTF8StringEncoding))
        }
    }
}
