/*
 * Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
 *
 * Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
 */

import Foundation

public enum LevelDBError: Error {
    case undefinedError
    case openError(message: String)
    case destroyError(message: String)
    case repairError(message: String)
    case readError(message: String)
    case writeError(message: String)
}

/** **A LevelDB database instance**
There should only be one instance created for a specific directory.
*/
public final class Database {
    typealias BatchUpdate = (WriteBatch) -> Void

    var pointer: OpaquePointer?
    let comparator: Comparator

    public class var majorVersion: Int {
        return Int(leveldb_major_version())
    }
    public class var minorVersion: Int {
        return Int(leveldb_minor_version())
    }

    /**
    :param directory  The directory for the database. This should already exist?
    */
    public class func create(path: String, options: [FileOption] = FileOption.standard, comparator: Comparator = DefaultComparator()) throws -> Database {
        var error: UnsafeMutablePointer<Int8>? = nil

        // open
        let options = FileOptions(options: options)
        let dbPointer = path.utf8CString.withUnsafeBufferPointer {
            return leveldb_open(options.pointer, $0.baseAddress!, &error)
        }

        // check if error
        guard let pointer = dbPointer else {
            if let error = error {
                throw LevelDBError.openError(message: String(cString: error))
            }

            throw LevelDBError.undefinedError
        }

        //
        return Database(pointer, comparator: comparator)
    }

    public class func destroy(path: String, options: [FileOption] = FileOption.standard) throws {
        var error: UnsafeMutablePointer<Int8>? = nil

        // close database
        let options = FileOptions(options: options)
        path.utf8CString.withUnsafeBufferPointer {
            leveldb_destroy_db(options.pointer, $0.baseAddress!, &error)
        }

        //
        if let error = error {
            throw LevelDBError.destroyError(message: String(cString: error))
        }
    }

    public class func repair(path: String, options: [FileOption] = FileOption.standard) throws {
        var error: UnsafeMutablePointer<Int8>? = nil

        // rapair
        let options = FileOptions(options: options)
        path.utf8CString.withUnsafeBufferPointer {
            leveldb_repair_db(options.pointer, $0.baseAddress!, &error)
        }

        //
        if let error = error {
            throw LevelDBError.repairError(message: String(cString: error))
        }
    }

    init(_ dbPointer: OpaquePointer, comparator: Comparator = DefaultComparator()) {
        self.pointer = dbPointer
        self.comparator = comparator
    }

    deinit {
        if pointer != nil {
            leveldb_close(pointer)
        }
    }

    public func get(_ key: Slice, options: [ReadOption] = ReadOption.standard) throws -> Data? {
        var valueLength = 0
        var error: UnsafeMutablePointer<Int8>? = nil
        var value: UnsafeMutablePointer<Int8>? = nil

        let options = ReadOptions(options: options)
        key.slice { (keyBytes, keyCount) in
            value = leveldb_get(pointer, options.pointer, keyBytes, keyCount, &valueLength, &error)
        }

        // throw if error
        guard error == nil else {
            throw LevelDBError.readError(message: String(cString: error!))
        }

        // check fetch value lenght
        guard valueLength > 0 else {
            return nil
        }

        // create data
        return Data(bytes: value!, count: valueLength)
    }

    public func put(_ key: Slice, value: Data?, options: [WriteOption] = WriteOption.standard) throws {
        var error: UnsafeMutablePointer<Int8>? = nil

        //
        let options = WriteOptions(options: options)
        key.slice { (keyBytes, keyCount) in
            if let value = value {
                value.withUnsafeBytes {
                    leveldb_put(pointer, options.pointer, keyBytes, keyCount, $0, value.count, &error)
                }
            } else {
                leveldb_put(pointer, options.pointer, keyBytes, keyCount, nil, 0, &error)
            }
        }

        // throw on error
        guard error == nil else {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }

    public func delete(_ key: Slice, options: [WriteOption] = WriteOption.standard) throws {
        var error: UnsafeMutablePointer<Int8>? = nil

        //
        let options = WriteOptions(options: options)
        key.slice { (keyBytes, keyCount) in
            leveldb_delete(pointer, options.pointer, keyBytes, keyCount, &error)
        }

        // throw on error
        guard error == nil else {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }

    public func write(options: [WriteOption] = WriteOption.standard, _ update: BatchUpdate) throws {
        var error: UnsafeMutablePointer<Int8>? = nil

        let batch = WriteBatch()
        update(batch)

        let options = WriteOptions(options: options)
        //
        leveldb_write(pointer, options.pointer, batch.pointer, &error)
        if error != nil {
            throw LevelDBError.writeError(message: String(cString: error!))
        }
    }

    public func keys(from: Data? = nil, to: Data? = nil, descending: Bool = false) -> KeySequence {
        let query = SequenceQuery(db: self, startKey: from, endKey: to, descending: descending)
        return KeySequence(query: query)
    }

    public func values(from: Data? = nil, to: Data? = nil, descending: Bool = false) -> KeyValueSequence {
        let query = SequenceQuery(db: self, startKey: from, endKey: to, descending: descending)
        return KeyValueSequence(query: query)
    }

    public func getSnapshot() -> Snapshot {
        return Snapshot(self)
    }

    /// Internal compare designed to be used for key bounds checking during iteration.
    func compare(_ a: Slice, _ b: Slice) -> ComparisonResult {
        return comparator.compare(a, b)
    }
}
