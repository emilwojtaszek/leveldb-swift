//
//  Deserializable.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public protocol Deserializable {
    init(entry: Entry)
}

public protocol Deserializer {
    func deserialize(data: Data) -> Entry?
    func deserialize(data: Data) -> [Entry]?
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
