/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public protocol Slice {
    func slice<ResultType>(_ f: (UnsafePointer<Int8>, Int) -> ResultType) -> ResultType
    func data() -> Data
}

extension Data: Slice {
    public func slice<ResultType>(_ f: (UnsafePointer<Int8>, Int) -> ResultType) -> ResultType {
        return self.withUnsafeBytes {
            f($0, self.count)
        }
    }

    public func data() -> Data {
        return self
    }
}

extension String: Slice {
    public func slice<ResultType>(_ f: (UnsafePointer<Int8>, Int) -> ResultType) -> ResultType {
        return self.utf8CString.withUnsafeBufferPointer {
            f($0.baseAddress!, Int(strlen($0.baseAddress!)))
        }
    }

    public func data() -> Data {
        return self.utf8CString.withUnsafeBufferPointer {
            return Data(buffer: $0)
        }
    }
}
