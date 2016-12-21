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
    public init(data: Data) {
        self.init(bytes: (data as NSData).bytes.bindMemory(to: Int8.self, capacity: data.count), length: data.count)
    }
    
    /// Converts the Slice to an NSData instance, copying by default.
    public func asData(copy: Bool = true) -> Data {
        if copy {
            return Data(bytes: self.bytes, count: self.length)
        } else {
            return Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: self.bytes), count: self.length, deallocator: .free)
        }
    }
    
    /// Coverts the Slice to a KeyType instance.
    public func asKey<Key: KeyType>() -> Key {
        return Key(bytes: UnsafeRawPointer(self.bytes), count: self.length)
    }
}

public protocol KeyType {
    init(bytes: UnsafeRawPointer, count: Int)
    func withSlice(_ f: (Slice) -> ())
    func asData() -> Data
}

extension Data: KeyType {
    public func withSlice(_ f: (Slice) -> ()) {
        f(Slice(bytes: (self as NSData).bytes.bindMemory(to: Int8.self, capacity: self.count), length: self.count))
    }
    
    public func asData() -> Data {
        return self
    }
}

extension String: KeyType {
    public init(bytes: UnsafeRawPointer, count: Int) {
        // append nul-terminator so we can use built-in UTF8 conversion 
        let data = UnsafeMutablePointer<Int8>.allocate(capacity: count + 1)
        data.assign(from: bytes.bindMemory(to: Int8.self, capacity: count), count: count)
        (data + count).pointee = 0
        self = String(cString: data)
    }
    
    public func withSlice(_ f: (Slice) -> ()) {
        self.withCString { (p: UnsafePointer<Int8>) -> () in
            var i = 0
            while (p + i).pointee != 0 { i += 1 }
            f(Slice(bytes: UnsafePointer<Int8>(p), length: i))
        }
    }
    
    public func asData() -> Data {
        return self.withCString { p in
            var i = 0
            while (p + i).pointee != 0 { i += 1 }
            return Data(bytes: p, count: i)
        }
    }
}
