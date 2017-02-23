//
//  Storage.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public final class Storage<D: DatabaseProtocol> {

    let database: D
    let configuration: StorageConfiguration

    public init(database: D, configuration: StorageConfiguration) {
        self.database = database
        self.configuration = configuration
    }
}

public extension Storage {

    func get(_ key: D.Key, options: [ReadOption] = ReadOption.standard) -> Data? {
        guard let data = try? database.get(key, options: options) else { return nil }

        return data.map { decoder.decode(data: $0) }
    }

    func put(_ key: D.Key, value: Data, options: [WriteOption] = WriteOption.standard) {
        let encoded = encoder.encode(data: value)

        try? database.put(key, value: encoded, options: options)
    }

    func delete(_ key: D.Key, options: [WriteOption] = WriteOption.standard) {
        try? database.delete(key, options: options)
    }
}

public extension Storage {
    func get<T: Deserializable>(_ key: D.Key, options: [ReadOption] = ReadOption.standard) -> T? {
        guard let data = get(key, options: options) else { return nil }

        return deserializer.deserialize(data: data)
    }

    func get<T: Deserializable>(_ key: D.Key, options: [ReadOption] = ReadOption.standard) -> [T]? {
        guard let data = get(key, options: options) else { return nil }

        return deserializer.deserialize(data: data)
    }

    func put<T: Serializable>(_ key: D.Key, value: T, options: [WriteOption] = WriteOption.standard) {
        guard let data = serializer.serialize(model: value) else { return }

        put(key, value: data, options: options)
    }

    func put<T: Serializable>(_ key: D.Key, value: [T], options: [WriteOption] = WriteOption.standard) {
        guard let data = serializer.serialize(array: value) else { return }

        put(key, value: data, options: options)
    }
}

public extension Storage {

    func get<T: Decodable>(_ key: D.Key, options: [ReadOption] = ReadOption.standard) -> T? {
        guard let data = get(key, options: options) else { return nil }

        return decoder.decode(data: data)
    }

    func put<T: Encodable>(_ key: D.Key, value: T, options: [WriteOption] = WriteOption.standard) {
        guard let data = encoder.encode(model: value) else { return }

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
