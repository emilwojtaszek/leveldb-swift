//
//  EncryptorDecryptor.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import CryptoSwift

public final class EncryptorDecryptor: Encoder, Decoder {
    private let aes: AES

    public convenience init() {
        self.init(key: "passwordpassword", iv: "drowssapdrowssap")
    }

    public init(key: String, iv: String) {
        aes = try! AES(key: key, iv: iv) // aes128
    }

    public func decode(data: Data) -> Data {
        return try! data.decrypt(cipher: aes)
    }

    public func encode(data: Data) -> Data {
        return try! data.encrypt(cipher: aes)
    }
}
