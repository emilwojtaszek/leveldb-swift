//
//  Serializable.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 21.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

typealias Entry = [String: Any]

protocol Serializable {
    func toEntry() -> Entry
}

protocol Deserializable {
    init(entry: Entry)
}

protocol Encoder {
    func encode(model: Entry) -> Data?
    func encode(models: [Entry]) -> Data?
}

protocol Decoder {
    func decode(modelData: Data) -> Entry?
    func decode(arrayData: Data) -> [Entry]?
}

extension Encoder {
    func encode<T: Serializable>(array: [T]) -> Data? {
        let models = array.map { $0.toEntry() }
        
        return encode(models: models)
    }
    
    func encode<T: Serializable>(model: T) -> Data? {
        let model = model.toEntry()
        
        return encode(model: model)
    }
}

extension Decoder {
    func decode<T: Deserializable>(data: Data) -> [T]? {
        let models = decode(arrayData: data)
        
        return models?.map { T(entry: $0) }
    }
    
    func decode<T: Deserializable>(data: Data) -> T? {
        let model = decode(modelData: data)
        
        return model.map { T(entry: $0) }
    }
}

struct DecoderEncoder: Decoder, Encoder {
    func encode(model: Entry) -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: model)
    }
    
    func encode(models: [Entry]) -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: models)
    }
    
    func decode(arrayData: Data) -> [Entry]? {
        return NSKeyedUnarchiver.unarchiveObject(with: arrayData) as? [Entry]
    }
    
    func decode(modelData: Data) -> Entry? {
        return NSKeyedUnarchiver.unarchiveObject(with: modelData) as? Entry
    }
}

final class Storage {
    let database: Database
    let encoder: Encoder
    let decoder: Decoder
    
    init(database: Database,
         encoder: Encoder = DecoderEncoder(),
         decoder: Decoder = DecoderEncoder()) {
        
        self.database = database
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func get<T: Deserializable>(_ key: Slice, options: ReadOptions = ReadOptions()) -> T? {
        guard let data = try? database.get(key, options: options) else { return nil }
        
        return data.flatMap { decoder.decode(data: $0) }
    }
    
    func get<T: Deserializable>(_ key: Slice, options: ReadOptions) -> [T]? {
        guard let data = try? database.get(key, options: options) else { return nil }
        
        return data.flatMap { decoder.decode(data: $0) }
    }
    
    func put<T: Serializable>(_ key: Slice, value: T, options: WriteOptions = WriteOptions()) {
        guard let data = encoder.encode(model: value) else { return }
        
        try? database.put(key, value: data, options: options)
    }
    
    func put<T: Serializable>(_ key: Slice, value: [T], options: WriteOptions = WriteOptions()) {
        guard let data = encoder.encode(array: value) else { return }
        
        try? database.put(key, value: data, options: options)
    }
    
    func delete(_ key: Slice, options: WriteOptions = WriteOptions()) {
        try? database.delete(key, options: options)
    }
}
