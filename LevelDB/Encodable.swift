//
//  Encodable.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public protocol Encodable {
    func toData() -> Data
}

public protocol Encoder {
    func encode(data: Data) -> Data
}

extension Encoder {
    func encode<T: Encodable>(model: T) -> Data? {
        let data = model.toData()

        return encode(data: data)
    }
}
