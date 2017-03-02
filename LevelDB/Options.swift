/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public enum CompressionType: Int {
    case none = 0
    case snappy
}

public protocol Option {
    func set(options: OpaquePointer)

    static var standard: [Self] { get }
}

public protocol Options: class {
    associatedtype OptionType: Option

    init(options: [OptionType])

    var pointer: OpaquePointer { get }
}

public enum FileOption: Option {
    case createIfMissing
    case errorIfExists
    case paranoidChecks
    case writeBufferSize(Int)
    case maxOpenFiles(Int)
    case blockSize(Int)
    case blockRestartInterval(Int)
    case compression(CompressionType)

    public func set(options: OpaquePointer) {
        switch self {
        case .createIfMissing:
            leveldb_options_set_create_if_missing(options, 1)
            break
        case .errorIfExists:
            leveldb_options_set_error_if_exists(options, 1)
            break
        case .paranoidChecks:
            leveldb_options_set_paranoid_checks(options, 1)
            break
        case .writeBufferSize(let size):
            leveldb_options_set_write_buffer_size(options, Int(size))
            break
        case .maxOpenFiles(let files):
            leveldb_options_set_max_open_files(options, Int32(files))
            break
        case .blockSize(let size):
            leveldb_options_set_block_size(options, Int(size))
            break
        case .blockRestartInterval(let interval):
            leveldb_options_set_block_restart_interval(options, Int32(interval))
            break
        case .compression(let type):
            leveldb_options_set_compression(options, Int32(type.rawValue))
            break
        }
    }

    public static var standard: [FileOption] {
        return [
            .writeBufferSize(1024 * 1024 * 4),
            .maxOpenFiles(1000),
            .blockSize(1024 * 4),
            .blockRestartInterval(16),
            .compression(.snappy)
        ]
    }
}

final public class FileOptions: Options {
    public let pointer: OpaquePointer

    public init(options: [FileOption]) {
        self.pointer = leveldb_options_create()
        options.forEach { $0.set(options: pointer) }
    }

    deinit {
        leveldb_options_destroy(pointer)
    }
}

public enum ReadOption: Option {
    case verifyChecksums
    case fillCache
    case snapshot(Snapshot)

    public func set(options: OpaquePointer) {
        switch self {
        case .verifyChecksums:
            leveldb_readoptions_set_verify_checksums(options, 1)
            break
        case .fillCache:
            leveldb_readoptions_set_fill_cache(options, 1)
            break
        case .snapshot(let snapshot):
            leveldb_readoptions_set_snapshot(options, snapshot.pointer)
            break
        }
    }

    public static var standard: [ReadOption] {
        return [
            .fillCache,
        ]
    }
}

final public class ReadOptions: Options {
    public let pointer: OpaquePointer

    public init(options: [ReadOption]) {
        self.pointer = leveldb_readoptions_create()
        options.forEach { $0.set(options: pointer) }
    }

    deinit {
        leveldb_readoptions_destroy(pointer)
    }
}

public enum WriteOption: Option {
    case sync

    public func set(options: OpaquePointer) {
        switch self {
        case .sync:
            leveldb_writeoptions_set_sync(options, 1)
            break
        }
    }

    public static var standard: [WriteOption] {
        return []
    }
}

final public class WriteOptions: Options {
    public let pointer: OpaquePointer

    public init(options: [WriteOption]) {
        self.pointer = leveldb_writeoptions_create()
        options.forEach { $0.set(options: pointer) }
    }

    deinit {
        leveldb_writeoptions_destroy(pointer)
    }
}
