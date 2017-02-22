//
//  Storage.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

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
