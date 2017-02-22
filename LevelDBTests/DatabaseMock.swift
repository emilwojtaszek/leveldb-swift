//
//  DatabaseMock.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

@testable import LevelDB

final class DatabaseMock: DatabaseProtocol {
    let mockedData: Data

    private(set) var deleteWasCalled = false
    private(set) var getWasCalled = false
    private(set) var putWasCalled = false

    init(mockedData: Data) {
        self.mockedData = mockedData
    }

    func delete(_ key: LevelDB.Slice, options: [WriteOption]) throws {
        deleteWasCalled = true
    }

    func get(_ key: LevelDB.Slice, options: [ReadOption]) throws -> Data? {
        getWasCalled = true
        return mockedData
    }

    func put(_ key: LevelDB.Slice, value: Data?, options: [WriteOption]) throws {
        putWasCalled = true
    }
}
