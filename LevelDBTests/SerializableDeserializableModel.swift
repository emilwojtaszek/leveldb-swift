//
//  SerializableDeserializableModel.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import LevelDB

struct SerializableDeserializableModel {
    let id: Int
    let name: String
}

extension SerializableDeserializableModel: Serializable {
    func toEntry() -> Entry {
        return ["id": id, "name": name]
    }
}

extension SerializableDeserializableModel: Deserializable {
    init(entry: Entry) {
        id = entry["id"] as! Int
        name = entry["name"] as! String
    }
}
