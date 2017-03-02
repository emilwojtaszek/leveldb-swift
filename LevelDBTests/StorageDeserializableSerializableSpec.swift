//
//  StorageDeserializableSerializableSpec.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Quick
import Nimble

import LevelDB

final class StorageSerializableDeserializableSpec: QuickSpec {
    override func spec() {
        describe("Storage") {
            var sut: Storage<DatabaseMock>!
            var database: DatabaseMock!

            context("when storing serializable") {

                var serializer: SerializerDeserializerMock!
                var encoder: EncoderDecoderMock!

                beforeEach {
                    let serializable = SerializableDeserializableModel(id: 10, name: "Some mocked string")

                    database = DatabaseMock()
                    encoder = EncoderDecoderMock()
                    serializer = SerializerDeserializerMock()

                    let configuration = StorageConfiguration(encoder: encoder, serializer: serializer)
                    sut = Storage(database: database, configuration: configuration)

                    sut.put("key", value: serializable)
                }

                it("puts data to database") {
                    expect(database.putWasCalled).to(beTrue())
                }

                it("encodes data") {
                    expect(encoder.encodeWasCalled).to(beTrue())
                }

                it("serializes data") {
                    expect(serializer.serializeWasCalled).to(beTrue())
                }
            }

            context("when storing serializable array") {

                var serializer: SerializerDeserializerMock!
                var encoder: EncoderDecoderMock!

                beforeEach {
                    let serializable = SerializableDeserializableModel(id: 10, name: "Some mocked string")

                    database = DatabaseMock()
                    encoder = EncoderDecoderMock()
                    serializer = SerializerDeserializerMock()

                    let configuration = StorageConfiguration(encoder: encoder, serializer: serializer)
                    sut = Storage(database: database, configuration: configuration)

                    sut.put("key", value: [serializable, serializable])
                }

                it("puts data to database") {
                    expect(database.putWasCalled).to(beTrue())
                }

                it("encodes data") {
                    expect(encoder.encodeWasCalled).to(beTrue())
                }

                it("serializes data") {
                    expect(serializer.serializeArrayWasCalled).to(beTrue())
                }
            }
            context("when retrieving decodable") {

                var decoder: EncoderDecoderMock!
                var deserializer: SerializerDeserializerMock!

                var deserializable: SerializableDeserializableModel!
                var retrievedObject: SerializableDeserializableModel!

                beforeEach {
                    deserializable = SerializableDeserializableModel(id: 10, name: "Some mocked string")

                    database = DatabaseMock()
                    decoder = EncoderDecoderMock()
                    deserializer = SerializerDeserializerMock(mockedEntry: deserializable.toEntry())

                    let configuration = StorageConfiguration(decoder: decoder, deserializer: deserializer)
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
                    expect(retrievedObject.id) == deserializable.id
                }

                it("deserializes data") {
                    expect(deserializer.deserializeWasCalled).to(beTrue())
                }
            }

            context("when retrieving decodable array") {

                var decoder: EncoderDecoderMock!
                var deserializer: SerializerDeserializerMock!

                var deserializableArray: [SerializableDeserializableModel]!
                var retrievedObjects: [SerializableDeserializableModel]!

                beforeEach {
                    deserializableArray = (1...3).map { SerializableDeserializableModel(id: $0, name: "Mock \($0)") }

                    database = DatabaseMock()
                    decoder = EncoderDecoderMock()
                    deserializer = SerializerDeserializerMock(mockedArray: deserializableArray.map { $0.toEntry() })

                    let configuration = StorageConfiguration(decoder: decoder, deserializer: deserializer)
                    sut = Storage(database: database, configuration: configuration)

                    retrievedObjects = sut.get("key")
                }

                it("gets data from database") {
                    expect(database.getWasCalled).to(beTrue())
                }

                it("decodes data") {
                    expect(decoder.decodeWasCalled).to(beTrue())
                }

                it("retrieves correct data") {
                    for (retrieved, deserializable) in zip(retrievedObjects, deserializableArray) {
                        expect(retrieved.id) == deserializable.id
                    }
                }

                it("deserializes data") {
                    expect(deserializer.deserializeArrayWasCalled).to(beTrue())
                }
            }
        }
    }
}
