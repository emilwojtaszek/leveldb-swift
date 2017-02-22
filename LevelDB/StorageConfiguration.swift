//
//  StorageConfiguration.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import Foundation

struct StorageConfiguration {
    let encoder: Encoder
    let decoder: Decoder

    let serializer: Serializer
    let deserializer: Deserializer

    init(encoder: Encoder,
         decoder: Decoder,
         serializer: Serializer,
         deserializer: Deserializer) {
        self.encoder = encoder
        self.decoder = decoder
        self.serializer = serializer
        self.deserializer = deserializer
    }
}
