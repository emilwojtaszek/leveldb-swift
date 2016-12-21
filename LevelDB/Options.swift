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

public protocol Comparator {
    var name: String { get }
    func compare(_ a: SliceProtocol, _ b: SliceProtocol) -> ComparisonResult
}

public protocol Options {
    
    /// Get initialized pointer to options C struct
    ///
    /// - Returns: Pointer to options struct
    func pointer() -> OpaquePointer
}

final public class FileOptions: Options {
    
    /// Private storage of C struct of options
    private let options: OpaquePointer

    /// Options properties
    var createIfMissing: Bool = false
    var errorIfExists: Bool = false
    var paranoidChecks: Bool = false
    var writeBufferSize: Int = 1024 * 1024 * 4 // 4MB default
    var maxOpenFiles: Int = 1000
    var blockSize: Int = 1024 * 4 // 4KB default
    var blockRestartInterval: Int = 16
    var compression: CompressionType = CompressionType.snappy
    var comparator: Comparator?
    
    ///
    init() {
        self.options = leveldb_options_create();
    }
    
    ///
    deinit {
        leveldb_options_destroy(options)
    }
    
    ///
    public func pointer() -> OpaquePointer {
        leveldb_options_set_block_restart_interval(options, Int32(blockRestartInterval))
        leveldb_options_set_block_size(options, Int(blockSize))
        leveldb_options_set_compression(options, Int32(compression.rawValue))
        leveldb_options_set_create_if_missing(options, createIfMissing ? 1: 0)
        leveldb_options_set_error_if_exists(options, errorIfExists ? 1: 0)
        leveldb_options_set_max_open_files(options, Int32(maxOpenFiles));
        leveldb_options_set_paranoid_checks(options, paranoidChecks ? 1: 0)
        leveldb_options_set_write_buffer_size(options, Int(writeBufferSize))
        
        
        
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
        
        return self.options;
    }
}

final public class ReadOptions: Options {
    /// Private storage of C struct of options
    private let options: OpaquePointer

    /// Options properties
    var verifyChecksums = false
    var fillCache = true
    var snapshot: Snapshot?
    
    ///
    init() {
        self.options = leveldb_readoptions_create();
    }
    
    ///
    deinit {
        leveldb_readoptions_destroy(options)
    }
    
    ///
    public func pointer() -> OpaquePointer {
        leveldb_readoptions_set_fill_cache(options, fillCache ? 1: 0)
        leveldb_readoptions_set_verify_checksums(options, verifyChecksums ? 1: 0)
        if snapshot != nil {
            leveldb_readoptions_set_snapshot(options, snapshot!.pointer)
        }

        return options;
    }
}

final public class WriteOptions: Options {
    /// Private storage of C struct of options
    private let options: OpaquePointer

    /// Options properties
    var sync = false
    
    ///
    init() {
        self.options = leveldb_writeoptions_create();
    }
    
    ///
    deinit {
        leveldb_writeoptions_destroy(options)
    }
    
    ///
    public func pointer() -> OpaquePointer {
        leveldb_writeoptions_set_sync(options, sync ? 1: 0)
        return options;
    }
}
