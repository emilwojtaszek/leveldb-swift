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

final class StorageDecodableEncodableSpec: QuickSpec {
    override func spec() {
        describe("Storage") {
            var sut: Storage<DatabaseMock>!
            var database: DatabaseMock!

            context("when storing encodable") {

                var encoder: EncoderDecoderMock!

                beforeEach {
                    let encodable = EncodableDecodableModel(id: 10, name: "Some mocked string")

                    database = DatabaseMock()
                    encoder = EncoderDecoderMock()

                    let configuration = StorageConfiguration(encoder: encoder)
                    sut = Storage(database: database, configuration: configuration)

                    sut.put("key", value: encodable)
                }

                it("puts data to database") {
                    expect(database.putWasCalled).to(beTrue())
                }

                it("encodes data") {
                    expect(encoder.encodeWasCalled).to(beTrue())
                }
            }

            context("when retrieving decodable") {

                var decoder: EncoderDecoderMock!
                var decodable: EncodableDecodableModel!
                var retrievedObject: EncodableDecodableModel!

                beforeEach {
                    decodable = EncodableDecodableModel(id: 10, name: "Some mocked string")

                    database = DatabaseMock(mockedData: decodable.toData())
                    decoder = EncoderDecoderMock()

                    let configuration = StorageConfiguration(decoder: decoder)
                    sut = Storage(database: database, configuration: configuration)

                    retrievedObject = sut.get("key")
                }

                it("gets data from database") {
                    expect(database.getWasCalled).to(beTrue())
                }

                it("decodes data") {
                    expect(decoder.decodeWasCalled).to(beTrue())
                }

                it("retrieves correct data") {
                    expect(retrievedObject.id) == decodable.id
                }
            }
        }
    }
}
