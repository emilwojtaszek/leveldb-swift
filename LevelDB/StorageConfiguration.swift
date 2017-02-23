//
//  StorageConfiguration.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

public struct StorageConfiguration {
    let encoder: Encoder
    let decoder: Decoder

    let serializer: Serializer
    let deserializer: Deserializer

    public init(encoder: Encoder = EncryptorDecryptor(),
                decoder: Decoder = EncryptorDecryptor(),
                serializer: Serializer = SerializerDeserializer(),
                deserializer: Deserializer = SerializerDeserializer()) {

        self.encoder = encoder
        self.decoder = decoder
        self.serializer = serializer
        self.deserializer = deserializer
    }
}
