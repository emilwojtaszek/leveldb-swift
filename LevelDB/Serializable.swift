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

protocol Serializer {
    func serialize(model: Entry) -> Data?
    func serialize(array: [Entry]) -> Data?
}

protocol Deserializer {
    func deserialize(data: Data) -> Entry?
    func deserialize(data: Data) -> [Entry]?
}

protocol Encodable {
    func toData() -> Data
}

protocol Decodable {
    init(data: Data)
}

protocol Encoder {
    func encode(data: Data) -> Data
    func encode(array: [Data]) -> Data
}

extension Encoder {
    func encode<T: Encodable>(model: T) -> Data? {
        let data = model.toData()
        
        return encode(data: data)
    }
    
    func encode<T: Encodable>(array: [T]) -> Data? {
        let dataArray = array.map { $0.toData() }
        
        return encode(array: dataArray)
    }
}

final class EncryptorDecryptor: Encoder, Decoder {
    func decode(data: Data) -> Data {
        return data
    }
    
    func encode(data: Data) -> Data {
        return data
    }
    
    func encode(array: [Data]) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: array)
    }
    
    func decode(data: Data) -> [Data] {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! [Data]
    }
}

protocol Decoder {
    func decode(data: Data) -> Data
    func decode(data: Data) -> [Data]
}

extension Decoder {
    func decode<T: Decodable>(data: Data) -> T? {
        let data: Data = decode(data: data)
        
        return T(data: data)
    }
    
    func decode<T: Decodable>(data: Data) -> [T]? {
        let dataArray: [Data] = decode(data: data)
        
        return dataArray.map { T(data: $0) }
    }
}

extension Serializer {
    func serialize<T: Serializable>(array: [T]) -> Data? {
        let models = array.map { $0.toEntry() }

        return serialize(array: models)
    }

    func serialize<T: Serializable>(model: T) -> Data? {
        let model = model.toEntry()

        return serialize(model: model)
    }
}

extension Deserializer {
    func deserialize<T: Deserializable>(data: Data) -> [T]? {
        let models: [Entry]? = deserialize(data: data)

        return models?.map { T(entry: $0) }
    }

    func deserialize<T: Deserializable>(data: Data) -> T? {
        let model: Entry? = deserialize(data: data)

        return model.map { T(entry: $0) }
    }
}

struct SerializerDeserializer: Serializer, Deserializer {
    func serialize(model: Entry) -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: model)
    }

    func serialize(array: [Entry]) -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: array)
    }

    func deserialize(data: Data) -> [Entry]? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Entry]
    }

    func deserialize(data: Data) -> Entry? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Entry
    }
}

struct StorageConfiguration {
    let encoder: Encoder
    let decoder: Decoder
    
    let serializer: Serializer
    let deserializer: Deserializer
    
    init(encoder: Encoder,
         decoder: Decoder,
         serializer: Serializer,
         deserializer: Deserializer) {
        self.encoder = encoder
        self.decoder = decoder
        self.serializer = serializer
        self.deserializer = deserializer
    }
}

final class Storage {
    
    let database: Database
    let configuration: StorageConfiguration

    init(database: Database, configuration: StorageConfiguration) {
        self.database = database
        self.configuration = configuration
    }
}

extension Storage {

    func get(_ key: Slice, options: [ReadOption] = ReadOption.standard) -> Data? {
        guard let data = try? database.get(key, options: options) else { return nil }
        
        return data.map { decoder.decode(data: $0) }
    }
    
    func put(_ key: Slice, value: Data, options: [WriteOption] = WriteOption.standard) {
        let encoded = encoder.encode(data: value)
        
        try? database.put(key, value: encoded, options: options)
    }
    
    func delete(_ key: Slice, options: [WriteOption] = WriteOption.standard) {
        try? database.delete(key, options: options)
    }
}

extension Storage {
    func get<T: Deserializable>(_ key: Slice, options: [ReadOption] = ReadOption.standard) -> T? {
        guard let data = get(key, options: options) else { return nil }
        
        return deserializer.deserialize(data: data)
    }
    
    func get<T: Deserializable>(_ key: Slice, options: [ReadOption] = ReadOption.standard) -> [T]? {
        guard let data = get(key, options: options) else { return nil }
        
        return deserializer.deserialize(data: data)
    }
    
    func put<T: Serializable>(_ key: Slice, value: T, options: [WriteOption] = WriteOption.standard) {
        guard let data = serializer.serialize(model: value) else { return }
        
        put(key, value: data, options: options)
    }
    
    func put<T: Serializable>(_ key: Slice, value: [T], options: [WriteOption] = WriteOption.standard) {
        guard let data = serializer.serialize(array: value) else { return }
        
        put(key, value: data, options: options)
    }
}

extension Storage {
    
    func get<T: Decodable>(_ key: Slice, options: [ReadOption] = ReadOption.standard) -> T? {
        guard let data = get(key, options: options) else { return nil }
        
        return decoder.decode(data: data)
    }
    
    func put<T: Encodable>(_ key: Slice, value: T, options: [WriteOption] = WriteOption.standard) {
        guard let data = encoder.encode(model: value) else { return }
        
        put(key, value: data, options: options)
    }
    
    func get<T: Decodable>(_ key: Slice, options: [ReadOption] = ReadOption.standard) -> [T]? {
        guard let data = get(key, options: options) else { return nil }
        
        return decoder.decode(data: data)
    }
    
    func put<T: Encodable>(_ key: Slice, value: [T], options: [WriteOption] = WriteOption.standard) {
        guard let data = encoder.encode(array: value) else { return }
        
        put(key, value: data, options: options)
    }
}

fileprivate extension Storage {
    var encoder: Encoder {
        return configuration.encoder
    }
    
    var decoder: Decoder {
        return configuration.decoder
    }
    
    var serializer: Serializer {
        return configuration.serializer
    }
    
    var deserializer: Deserializer {
        return configuration.deserializer
    }
}
