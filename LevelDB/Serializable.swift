//
//  Serializable.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 21.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public typealias Entry = [String: Any]

public protocol Serializable {
    func toEntry() -> Entry
}

public protocol Serializer {
    func serialize(model: Entry) -> Data?
    func serialize(array: [Entry]) -> Data?
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
