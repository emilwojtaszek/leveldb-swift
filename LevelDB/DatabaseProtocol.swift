//
//  DatabaseProtocol.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public protocol DatabaseProtocol {
    func get(_ key: Slice, options: [ReadOption]) throws -> Data?
    func put(_ key: Slice, value: Data?, options: [WriteOption]) throws
    func delete(_ key: Slice, options: [WriteOption]) throws
}

extension Database : DatabaseProtocol {}
