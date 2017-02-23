//
//  EncryptorDecryptor.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public final class EncryptorDecryptor: Encoder, Decoder {
    public init() {}

    public func decode(data: Data) -> Data {
        return data
    }

    public func encode(data: Data) -> Data {
        return data
    }
}
