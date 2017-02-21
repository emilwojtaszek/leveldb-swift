//
//  Serializable.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 21.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

typealias LevelDBModel = [String: Any]

protocol LevelDBSerializable {
    func toLevelDBModel() -> LevelDBModel
}

protocol LevelDBDeserializable {
    init(levelDBmodel: LevelDBModel)
}

protocol LevelDBEncoder {
    func encode(model: LevelDBModel) -> Data?
    func encode(models: [LevelDBModel]) -> Data?
}

protocol LevelDBDecoder {
    func decode(modelData: Data) -> LevelDBModel?
    func decode(arrayData: Data) -> [LevelDBModel]?
}

extension LevelDBEncoder {
    func encode<T: LevelDBSerializable>(array: [T]) -> Data? {
        let models = array.map { $0.toLevelDBModel() }
        
        return encode(models: models)
    }
    
    func encode<T: LevelDBSerializable>(model: T) -> Data? {
        let model = model.toLevelDBModel()
        
        return encode(model: model)
    }
}

extension LevelDBDecoder {
    func decode<T: LevelDBDeserializable>(data: Data) -> [T]? {
        let models = decode(arrayData: data)
        
        return models?.map { T(levelDBmodel: $0) }
    }
    
    func decode<T: LevelDBDeserializable>(data: Data) -> T? {
        let model = decode(modelData: data)
        
        return model.map { T(levelDBmodel: $0) }
    }
}

struct LevelDBDecoderEncoder: LevelDBDecoder, LevelDBEncoder {
    func encode(model: LevelDBModel) -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: model)
    }
    
    func encode(models: [LevelDBModel]) -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: models)
    }
    
    func decode(arrayData: Data) -> [LevelDBModel]? {
        return NSKeyedUnarchiver.unarchiveObject(with: arrayData) as? [LevelDBModel]
    }
    
    func decode(modelData: Data) -> LevelDBModel? {
        return NSKeyedUnarchiver.unarchiveObject(with: modelData) as? LevelDBModel
    }
}

final class Storage {
    let database: Database
    let encoder: LevelDBEncoder
    let decoder: LevelDBDecoder
    
    init(database: Database,
         encoder: LevelDBEncoder = LevelDBDecoderEncoder(),
         decoder: LevelDBDecoder = LevelDBDecoderEncoder()) {
        
        self.database = database
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func get<T: LevelDBDeserializable>(_ key: Slice, options: ReadOptions = ReadOptions()) -> T? {
        guard let data = try? database.get(key, options: options) else { return nil }
        
        return data.flatMap { decoder.decode(data: $0) }
    }
    
    func get<T: LevelDBDeserializable>(_ key: Slice, options: ReadOptions) -> [T]? {
        guard let data = try? database.get(key, options: options) else { return nil }
        
        return data.flatMap { decoder.decode(data: $0) }
    }
    
    func put<T: LevelDBSerializable>(_ key: Slice, value: T, options: WriteOptions = WriteOptions()) {
        guard let data = encoder.encode(model: value) else { return }
        
        try? database.put(key, value: data, options: options)
    }
    
    func put<T: LevelDBSerializable>(_ key: Slice, value: [T], options: WriteOptions = WriteOptions()) {
        guard let data = encoder.encode(array: value) else { return }
        
        try? database.put(key, value: data, options: options)
    }
    
    func delete(_ key: Slice, options: WriteOptions = WriteOptions()) {
        try? database.delete(key, options: options)
    }
}


