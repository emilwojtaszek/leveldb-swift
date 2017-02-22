//
//  Encodable.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

protocol Encodable {
    func toData() -> Data
}

protocol Encoder {
    func encode(data: Data) -> Data
    func encode(array: [Data]) -> Data
}

extension Encoder {
    func encode<T: Encodable>(model: T) -> Data? {
        let data = model.toData()
        
        return encode(data: data)
    }
    
    func encode<T: Encodable>(array: [T]) -> Data? {
        let dataArray = array.map { $0.toData() }
        
        return encode(array: dataArray)
    }
}
