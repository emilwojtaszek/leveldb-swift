//
//  EncryptorDecryptorSpec.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Quick
import Nimble

@testable import LevelDB

final class EncryptorDecryptorSpec: QuickSpec {
    override func spec() {
        describe("Storage") {
            var sut: EncryptorDecryptor!

            beforeEach {
                sut = EncryptorDecryptor()
            }

            context("when storing data") {

            }
        }
    }
}
