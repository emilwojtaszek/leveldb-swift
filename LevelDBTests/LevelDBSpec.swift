//
//  LevelDBSpec.swift
//  LevelDB
//
//  Created by Sam Ritchie on 10/08/2015.
//  Copyright © 2015 codesplice. All rights reserved.
//

//import Foundation
//import XCTest
//import LevelDB
//import SwiftCheck
//
//let nonEmptyString = String.arbitrary.suchThat { !$0.isEmpty }
//
//enum DBOperation: CustomDebugStringConvertible {
//    case put(key: String, value: [Int8])
//    case get(key: String)
//    case delete(key: String)
//    
//    var debugDescription: String {
//        switch(self) {
//        case let .put(k, s):
//            return "Put \(k): \(s)"
//        case let .get(k):
//            return "Get \(k)"
//        case let .delete(k):
//            return "Delete \(k)"
//        }
//    }
//}
//
//extension DBOperation: Arbitrary {
//    static var arbitrary: SwiftCheck.Gen<DBOperation> {
//        return Gen.oneOf([
//                    DBOperation.Get <^> nonEmptyString,
//                    DBOperation.Delete <^> nonEmptyString
//                ])
//    }
//}
//
//extension Database: Arbitrary, CustomDebugStringConvertible {
//    
//    public static func create(_ values: DictionaryOf<String, ArrayOf<Int8>>) -> Database {
//        let id = UUID().description
//        #if TARGET_OS_IPHONE
//            let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//            let directory = (dirs as [String])[0].stringByAppendingPathComponent(id)
//        #else
//            let directory = NSString(string:NSTemporaryDirectory()).appendingPathComponent(id)
//        #endif
//        do {
//            try FileManager.default.removeItem(atPath: directory)
//        } catch _ { /* swallow */ }
//        let db = try! Database.createDatabase(directory, options: Options(createIfMissing: true))
//        for (k, v) in values.getDictionary {
//            v.getArray.withUnsafeBufferPointer() { p in
//                try! db.put(k, value: NSData(bytes: UnsafePointer<Void>(p.baseAddress), length: v.getArray.count))
//            }
//        }
//        return db
//    }
//    
//    public static var arbitrary: SwiftCheck.Gen<Database> {
//        return Database.create <^> DictionaryOf<String, ArrayOf<Int8>>.arbitrary
//    }
//    
//    public var debugDescription: String {
//        var str = "["
//        for (k, v) in self.values() {
//            str += "\(k): \(v),\n"
//        }
//        str += "]"
//        return str
//    }
//}
//
//class LevelDBTest: XCTestCase {
//
//    func testGetAndPut() {
//        property("Put and retrieve a single value") <- forAll(Database.arbitrary)(genB: String.arbitrary.suchThat({ !$0.isEmpty }))(genC: ArrayOf<Int8>.arbitrary)(pf: { (db, k, v) in
//            let data = v.getArray.withUnsafeBufferPointer() { p in
//                return NSData(bytes: UnsafePointer<Void>(p.baseAddress), length: v.getArray.count)
//            }
//
//            /*
//            Uncomment to watch SwiftCheck do its stuff!
//            print("Key = \(k)")
//            print("Value = \(v)")
//            print("DB = \(db)")
//            */
//            
//            try! db.put(k, value: data)
//            let returnedData = try! db.get(k)
//            
//            if v.getArray.isEmpty {
//                return returnedData == nil
//            } else {
//                return returnedData!.isEqualToData(data) ?? false
//            }
//        })
//    }
//}
