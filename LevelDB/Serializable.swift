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
    func encode(array: [Entry]) -> Data?
}

protocol Decoder {
    func decode(data: Data) -> Entry?
    func decode(data: Data) -> [Entry]?
}

extension Encoder {
    func encode<T: Serializable>(array: [T]) -> Data? {
        let models = array.map { $0.toEntry() }

        return encode(array: models)
    }

    func encode<T: Serializable>(model: T) -> Data? {
        let model = model.toEntry()

        return encode(model: model)
    }
}

extension Decoder {
    func decode<T: Deserializable>(data: Data) -> [T]? {
        let models: [Entry]? = decode(data: data)

        return models?.map { T(entry: $0) }
    }

    func decode<T: Deserializable>(data: Data) -> T? {
        let model: Entry? = decode(data: data)

        return model.map { T(entry: $0) }
    }
}

struct DecoderEncoder: Decoder, Encoder {
    func encode(model: Entry) -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: model)
    }

    func encode(array: [Entry]) -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: array)
    }

    func decode(data: Data) -> [Entry]? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? [Entry]
    }

    func decode(data: Data) -> Entry? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Entry
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

    func get<T: Deserializable>(_ key: Slice, options: [ReadOption] = ReadOption.standard) -> T? {
        guard let data = try? database.get(key, options: options) else { return nil }

        return data.flatMap { decoder.decode(data: $0) }
    }

    func get<T: Deserializable>(_ key: Slice, options: [ReadOption] = ReadOption.standard) -> [T]? {
        guard let data = try? database.get(key, options: options) else { return nil }

        return data.flatMap { decoder.decode(data: $0) }
    }

    func put<T: Serializable>(_ key: Slice, value: T, options: [WriteOption] = WriteOption.standard) {
        guard let data = encoder.encode(model: value) else { return }

        try? database.put(key, value: data, options: options)
    }

    func put<T: Serializable>(_ key: Slice, value: [T], options: [WriteOption] = WriteOption.standard) {
        guard let data = encoder.encode(array: value) else { return }

        try? database.put(key, value: data, options: options)
    }

    func delete(_ key: Slice, options: [WriteOption] = WriteOption.standard) {
        try? database.delete(key, options: options)
    }
}
