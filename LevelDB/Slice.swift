/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public protocol SliceProtocol {
    func slice<ResultType>(_ f: (UnsafePointer<Int8>, Int) -> ResultType) -> ResultType
    func data() -> Data
}

extension Data: SliceProtocol {
    public func slice<ResultType>(_ f: (UnsafePointer<Int8>, Int) -> ResultType) -> ResultType {
        return self.withUnsafeBytes {
            return f($0, self.count)
        }
    }

    public func data() -> Data {
        return self
    }
}

extension String: SliceProtocol {
    public func slice<ResultType>(_ f: (UnsafePointer<Int8>, Int) -> ResultType) -> ResultType {
        let data = self.data()
        return data.withUnsafeBytes {
            return f($0, data.count)
        }
    }
    
    public func data() -> Data {
        return self.data(using: .utf8)!
    }
}
