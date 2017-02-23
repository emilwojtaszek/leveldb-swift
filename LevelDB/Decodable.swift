//
//  Decodable.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public protocol Decodable {
    init(data: Data)
}

public protocol Decoder {
    func decode(data: Data) -> Data
}

extension Decoder {
    func decode<T: Decodable>(data: Data) -> T? {
        let data: Data = decode(data: data)

        return T(data: data)
    }
}
