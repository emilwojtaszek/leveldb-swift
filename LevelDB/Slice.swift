/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

/**
 * Swift Analog of the LevelDB Slice type. This is a lightweight pointer to temporary memory managed by LevelDB.
 * Client code should copy the memory in most scenarios.
 */
//public typealias Slice = UnsafeBufferPointer<Int8>
public struct Slice {
    public let bytes: UnsafePointer<Int8>
    public let length: Int
}

extension Slice {
    
    /// Initialises a Slice from an NSData instance.
    public init(data: NSData) {
        self.init(bytes: UnsafePointer<Int8>(data.bytes), length: data.length)
    }
    
    /// Converts the Slice to an NSData instance, copying by default.
    public func asData(copy copy: Bool = true) -> NSData {
        if copy {
            return NSData(bytes: UnsafePointer<Void>(self.bytes), length: self.length)
        } else {
            return NSData(bytesNoCopy: UnsafeMutablePointer<Void>(self.bytes), length: self.length, freeWhenDone:true)
        }
    }
    
    /// Coverts the Slice to a KeyType instance.
    public func asKey<Key: KeyType>() -> Key {
        return Key(bytes: UnsafePointer<Void>(self.bytes), length: self.length)
    }
}

public protocol KeyType {
    init(bytes: UnsafePointer<Void>, length: Int)
    func withSlice(@noescape f: (Slice) -> ())
    func asData() -> NSData
}

extension NSData: KeyType {
    public func withSlice(@noescape f: (Slice) -> ()) {
        f(Slice(bytes: UnsafePointer<Int8>(self.bytes), length: self.length))
    }
    
    public func asData() -> NSData {
        return self
    }
}

extension String: KeyType {
    public init(bytes: UnsafePointer<Void>, length: Int) {
        // append nul-terminator so we can use built-in UTF8 conversion 
        let data = UnsafeMutablePointer<Int8>.alloc(length + 1)
        data.assignFrom(UnsafeMutablePointer<Int8>(bytes), count: length)
        (data + length).memory = 0
        self = String.fromCString(data)!
    }
    
    public func withSlice(@noescape f: (Slice) -> ()) {
        self.withCString { (p : UnsafePointer<Int8>) -> () in
            var i = 0
            while (p + i).memory != 0 { i++ }
            f(Slice(bytes: UnsafePointer<Int8>(p), length: i))
        }
    }
    
    public func asData() -> NSData {
        return self.withCString { p in
            var i = 0
            while (p + i).memory != 0 { i++ }
            return NSData(bytes: p, length: i)
        }
    }
}
