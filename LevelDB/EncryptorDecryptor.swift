//
//  EncryptorDecryptor.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

final class EncryptorDecryptor: Encoder, Decoder {
    func decode(data: Data) -> Data {
        return data
    }
    
    func encode(data: Data) -> Data {
        return data
    }
    
    func encode(array: [Data]) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: array)
    }
    
    func decode(data: Data) -> [Data] {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! [Data]
    }
}
