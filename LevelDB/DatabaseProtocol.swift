//
//  DatabaseProtocol.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public protocol DatabaseProtocol {
    associatedtype Key

    func get(_ key: Key, options: [ReadOption]) throws -> Data?
    func put(_ key: Key, value: Data?, options: [WriteOption]) throws
    func delete(_ key: Key, options: [WriteOption]) throws
}

extension Database : DatabaseProtocol {}
