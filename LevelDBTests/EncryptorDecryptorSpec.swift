//
//  EncryptorDecryptorSpec.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Quick
import Nimble
import CryptoSwift

@testable import LevelDB

final class EncryptorDecryptorSpec: QuickSpec {
    override func spec() {
        describe("Storage") {
            var sut: EncryptorDecryptor!
            var cipher: AES!

            beforeEach {
                let key = "passwordpassword"
                let iv  = "thismustbe16char"

                cipher = try! AES(key: key, iv: iv)
                sut = EncryptorDecryptor(key: key, iv: iv)
            }

            it ("encrypts data with aes") {
                let model = EncodableDecodableModel(id: 10, name: "mock")

                let data = model.toData()
                let encoded = sut.encode(data: data)

                let decoded = try! encoded.decrypt(cipher: cipher)
                let decodedModel = EncodableDecodableModel(data: decoded)

                expect(model.id) == decodedModel.id
            }

            it ("decrypts data with aes") {
                let model = EncodableDecodableModel(id: 10, name: "mock")

                let data = model.toData()
                let encoded = try! data.encrypt(cipher: cipher)

                let decoded = sut.decode(data: encoded)
                let decodedModel = EncodableDecodableModel(data: decoded)

                expect(model.id) == decodedModel.id
            }
        }
    }
}
