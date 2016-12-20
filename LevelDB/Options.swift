/*
* Copyright © 2014, codesplice pty ltd (sam@codesplice.com.au)
*
* Licensed under the terms of the ISC License http://opensource.org/licenses/ISC
*/

import Foundation

public enum CompressionType : Int {
    case noCompression = 0
    case snappyCompression
}

public protocol Comparator {
    var name : String { get }
    func compare(_ a : Slice, _ b : Slice) -> ComparisonResult
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
        compression : CompressionType = CompressionType.snappyCompression,
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
    
    func asCPointer() -> OpaquePointer {
        let opt = leveldb_options_create();
        leveldb_options_set_block_restart_interval(opt, Int32(blockRestartInterval))
        leveldb_options_set_block_size(opt, Int(blockSize))
        leveldb_options_set_compression(opt, Int32(compression.rawValue))
        leveldb_options_set_create_if_missing(opt, createIfMissing ? 1 : 0)
        leveldb_options_set_error_if_exists(opt, errorIfExists ? 1 : 0)
        leveldb_options_set_max_open_files(opt, Int32(maxOpenFiles));
        leveldb_options_set_paranoid_checks(opt, paranoidChecks ? 1 : 0)
        leveldb_options_set_write_buffer_size(opt, Int(writeBufferSize))
        
//        if let comparatorObj = comparator {
//            let state = UnsafeMutablePointer<Comparator>.allocate(capacity: 1)
//            state.initialize(to: comparatorObj)
//
//            let cmp = leveldb_comparator_create(UnsafeMutableRawPointer(state),
//                { s in
//                    UnsafeMutablePointer<Comparator>(s).deinitialize()
//                },
//                { s, a, alen, b, blen in
//                    let c = UnsafeMutablePointer<Comparator>(s).pointee
//                    let aSlice = Slice(bytes: a, length: alen)
//                    let bSlice = Slice(bytes: b, length: blen)
//                    return CInt(c.compare(aSlice, bSlice).rawValue)
//                },
//                { s in
//                    // TODO: avoid NSString bridge?
//                    (UnsafeMutablePointer<Comparator>(s).pointee.name as NSString).utf8String
//                })
//            leveldb_options_set_comparator(opt, cmp)
//        }
//        // TODO: Filter policy
        
        return opt!;
    }
}

public struct ReadOptions {
    public let verifyChecksums = false
    public let fillCache = true
    public let snapshot : Snapshot? = nil
    func asCPointer() -> OpaquePointer {
        let opt = leveldb_readoptions_create();
        leveldb_readoptions_set_fill_cache(opt, fillCache ? 1 : 0)
        leveldb_readoptions_set_verify_checksums(opt, verifyChecksums ? 1 : 0)
        if snapshot != nil {
            leveldb_readoptions_set_snapshot(opt, snapshot!.pointer)
        }
        return opt!;
    }
}

public struct WriteOptions {
    public let sync = false
    func asCPointer() -> OpaquePointer {
        let opt = leveldb_writeoptions_create();
        leveldb_writeoptions_set_sync(opt, sync ? 1 : 0)
        return opt!;
    }
}
