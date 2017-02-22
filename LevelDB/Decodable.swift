//
//  Decodable.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

protocol Decodable {
    init(data: Data)
}

protocol Decoder {
    func decode(data: Data) -> Data
    func decode(data: Data) -> [Data]
}

extension Decoder {
    func decode<T: Decodable>(data: Data) -> T? {
        let data: Data = decode(data: data)

        return T(data: data)
    }

    func decode<T: Decodable>(data: Data) -> [T]? {
        let dataArray: [Data] = decode(data: data)

        return dataArray.map { T(data: $0) }
    }
}
