/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public enum CompressionType : Int {
    case NoCompression = 0
    case SnappyCompression
}

public protocol Comparator {
    var name : String { get }
    func compare(a : NSData, _ b : NSData) -> NSComparisonResult
}

public struct Options {
    public let createIfMissing : Bool
    public let errorIfExists : Bool
    public let paranoidChecks  : Bool
    public let writeBufferSize : Int
    public let maxOpenFiles : Int
    public let blockSize : Int
    public let blockRestartInterval : Int
    public let compression : CompressionType
    public let comparator : Comparator?
    
    public init(createIfMissing : Bool = false,
        errorIfExists : Bool = false,
        paranoidChecks : Bool = false,
        writeBufferSize : Int = 1024 * 1024 * 4, // 4MB default
        maxOpenFiles : Int = 1000,
        blockSize : Int = 1024 * 4, // 4KB default
        blockRestartInterval : Int = 16,
        compression : CompressionType = CompressionType.SnappyCompression,
        comparator : Comparator? = nil) {
            
        self.createIfMissing = createIfMissing
        self.errorIfExists = errorIfExists
        self.paranoidChecks = paranoidChecks
        self.writeBufferSize = writeBufferSize
        self.maxOpenFiles = maxOpenFiles
        self.blockSize = blockSize
        self.blockRestartInterval = blockRestartInterval
        self.compression = compression
        self.comparator = comparator
    }
    
    func asCPointer() -> COpaquePointer {
        let opt = leveldb_options_create();
        leveldb_options_set_block_restart_interval(opt, CInt(blockRestartInterval))
        leveldb_options_set_block_size(opt, blockSize.asUnsigned())
        leveldb_options_set_compression(opt, CInt(compression.toRaw()))
        leveldb_options_set_create_if_missing(opt, createIfMissing ? 1 : 0)
        leveldb_options_set_error_if_exists(opt, errorIfExists ? 1 : 0)
        leveldb_options_set_max_open_files(opt, CInt(maxOpenFiles));
        leveldb_options_set_paranoid_checks(opt, paranoidChecks ? 1 : 0)
        leveldb_options_set_write_buffer_size(opt, writeBufferSize.asUnsigned())

        // TODO: Comparator
        
        if let comparatorObj = comparator {
            let compareClosure : (ConstUnsafePointer<Int8>, UInt, ConstUnsafePointer<Int8>, UInt) -> CInt =
            {(a, alen, b, blen) in
                let aData = NSData(bytes: a, length: alen.asSigned())
                let bData = NSData(bytes: b, length: blen.asSigned())
                return CInt(comparatorObj.compare(aData, bData).toRaw())
                };
            var name : ConstUnsafePointer<Int8> = nil
            comparatorObj.name.withCString({
                name = $0
            })
            let cmp = leveldb_comparator_create_wrapper(name, compareClosure)
            leveldb_options_set_comparator(opt, cmp);
        }
        // TODO: Filter policy
        
        return opt;
    }
}

public struct ReadOptions {
    public let verifyChecksums = false
    public let fillCache = true
    public let snapshot : Snapshot? = nil
    func asCPointer() -> COpaquePointer {
        let opt = leveldb_readoptions_create();
        leveldb_readoptions_set_fill_cache(opt, fillCache ? 1 : 0)
        leveldb_readoptions_set_verify_checksums(opt, verifyChecksums ? 1 : 0)
        if snapshot {
            leveldb_readoptions_set_snapshot(opt, snapshot!.pointer)
        }
        return opt;
    }
}

public struct WriteOptions {
    public let sync = false
    func asCPointer() -> COpaquePointer {
        let opt = leveldb_writeoptions_create();
        leveldb_writeoptions_set_sync(opt, sync ? 1 : 0)
        return opt;
    }
}
