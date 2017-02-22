//
//  EncoderDecoderMock.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import LevelDB

final class EncoderDecoderMock: Encoder, Decoder {
    let mockedData: Data
    let mockedArray: [Data]

    private(set) var encodeArrayWasCalled: Bool = false
    private(set) var encodeWasCalled: Bool = false
    private(set) var decodeArrayWasCalled: Bool = false
    private(set) var decodeWasCalled: Bool = false

    init(mockedData: Data = Data(), mockedArray: [Data] = []) {
        self.mockedData = mockedData
        self.mockedArray = mockedArray
    }

    func encode(array: [Data]) -> Data {
        encodeArrayWasCalled = true
        return mockedData
    }

    func encode(data: Data) -> Data {
        encodeWasCalled = true
        return mockedData
    }

    func decode(data: Data) -> [Data] {
        decodeArrayWasCalled = true
        return mockedArray
    }

    func decode(data: Data) -> Data {
        decodeWasCalled = true
        return mockedData
    }
}
