//
//  SerializerDeserializer.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

final class SerializerDeserializer: Serializer, Deserializer {
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
