//
//  File.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import LevelDB

final class SerializerDeserializerMock: Serializer, Deserializer {
    let mockedData: Data
    let mockedEntry: Entry
    let mockedArray: [Entry]

    private(set) var serializeArrayWasCalled: Bool = false
    private(set) var serializeWasCalled: Bool = false
    private(set) var deserializeArrayWasCalled: Bool = false
    private(set) var deserializeWasCalled: Bool = false

    init(mockedData: Data = Data(), mockedEntry: Entry = [:], mockedArray: [Entry] = []) {
        self.mockedData = mockedData
        self.mockedArray = mockedArray
        self.mockedEntry = mockedEntry
    }

    func serialize(model: Entry) -> Data? {
        serializeWasCalled = true
        return mockedData
    }

    func deserialize(data: Data) -> Entry? {
        deserializeWasCalled = true
        return mockedEntry
    }

    func serialize(array: [Entry]) -> Data? {
        serializeArrayWasCalled = true
        return mockedData
    }

    func deserialize(data: Data) -> [Entry]? {
        deserializeArrayWasCalled = true
        return mockedArray
    }
}
