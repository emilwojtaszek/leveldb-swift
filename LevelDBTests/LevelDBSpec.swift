//
//  LevelDBSpec.swift
//  LevelDB
//
//  Created by Sam Ritchie on 10/08/2015.
//  Copyright © 2015 codesplice. All rights reserved.
//

import Foundation
import XCTest
import LevelDB
import SwiftCheck

let nonEmptyString = String.arbitrary.suchThat { !$0.isEmpty }

enum DBOperation: CustomDebugStringConvertible {
    case Put(key: String, value: [Int8])
    case Get(key: String)
    case Delete(key: String)
    
    var debugDescription: String {
        switch(self) {
        case let .Put(k, s):
            return "Put \(k): \(s)"
        case let .Get(k):
            return "Get \(k)"
        case let .Delete(k):
            return "Delete \(k)"
        }
    }
}

extension DBOperation: Arbitrary {
    static var arbitrary: SwiftCheck.Gen<DBOperation> {
        return Gen.oneOf([
                    DBOperation.Get <^> nonEmptyString,
                    DBOperation.Delete <^> nonEmptyString
                ])
    }
}

extension Database: Arbitrary, CustomDebugStringConvertible {
    
    public static func create(values: DictionaryOf<String, ArrayOf<Int8>>) -> Database {
        let id = NSUUID().description
        #if TARGET_OS_IPHONE
            let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let directory = (dirs as [String])[0].stringByAppendingPathComponent(id)
        #else
            let directory = NSString(string:NSTemporaryDirectory()).stringByAppendingPathComponent(id)
        #endif
        do {
            try NSFileManager.defaultManager().removeItemAtPath(directory)
        } catch _ { /* swallow */ }
        let db = try! Database.createDatabase(directory, options: Options(createIfMissing: true))
        for (k, v) in values.getDictionary {
            v.getArray.withUnsafeBufferPointer() { p in
                try! db.put(k, value: NSData(bytes: UnsafePointer<Void>(p.baseAddress), length: v.getArray.count))
            }
        }
        return db
    }
    
    public static var arbitrary: SwiftCheck.Gen<Database> {
        return Database.create <^> DictionaryOf<String, ArrayOf<Int8>>.arbitrary
    }
    
    public var debugDescription: String {
        var str = "["
        for (k, v) in self.values() {
            str += "\(k): \(v),\n"
        }
        str += "]"
        return str
    }
}

class LevelDBTest: XCTestCase {

    func testGetAndPut() {
        property("Put and retrieve a single value") <- forAll(Database.arbitrary)(genB: String.arbitrary.suchThat({ !$0.isEmpty }))(genC: ArrayOf<Int8>.arbitrary)(pf: { (db, k, v) in
            let data = v.getArray.withUnsafeBufferPointer() { p in
                return NSData(bytes: UnsafePointer<Void>(p.baseAddress), length: v.getArray.count)
            }

            /*
            Uncomment to watch SwiftCheck do its stuff!
            print("Key = \(k)")
            print("Value = \(v)")
            print("DB = \(db)")
            */
            
            try! db.put(k, value: data)
            let returnedData = try! db.get(k)
            
            if v.getArray.isEmpty {
                return returnedData == nil
            } else {
                return returnedData!.isEqualToData(data) ?? false
            }
        })
    }
}