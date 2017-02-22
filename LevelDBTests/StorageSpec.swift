//
//  StorageSpec.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Quick
import Nimble

import LevelDB

final class StorageSpec: QuickSpec {
    override func spec() {
        describe("Storage") {
            var sut: Storage!
            var database: DatabaseMock!

            context("when storing data") {

                var encoder: EncoderDecoderMock!

                beforeEach {
                    database = DatabaseMock()
                    encoder = EncoderDecoderMock()

                    let configuration = StorageConfiguration(encoder: encoder)
                    sut = Storage(database: database, configuration: configuration)

                    sut.put("key", value: Data())
                }

                it("puts data to database") {
                    expect(database.putWasCalled).to(beTrue())
                }

                it("encodes data") {
                    expect(encoder.encodeWasCalled).to(beTrue())
                }
            }

            context("when retrieving data") {

                var decoder: EncoderDecoderMock!

                beforeEach {

                    database = DatabaseMock()
                    decoder = EncoderDecoderMock()

                    let configuration = StorageConfiguration(decoder: decoder)
                    sut = Storage(database: database, configuration: configuration)

                    let retrievedData: Data? = sut.get("key")
                }

                it("gets data from database") {
                    expect(database.getWasCalled).to(beTrue())
                }

                it("decodes data") {
                    expect(decoder.decodeWasCalled).to(beTrue())
                }
            }

            context("when deleting data") {

                beforeEach {
                    database = DatabaseMock()

                    let configuration = StorageConfiguration()
                    sut = Storage(database: database, configuration: configuration)

                    sut.delete("key")
                }

                it("deletes data from database") {
                    expect(database.deleteWasCalled).to(beTrue())
                }
            }
        }
    }
}
