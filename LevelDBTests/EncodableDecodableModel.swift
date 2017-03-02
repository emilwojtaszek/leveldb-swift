//
//  EncodableDecodableModel.swift
//  LevelDB
//
//  Created by Krzysztof Kapitan on 22.02.2017.
//  Copyright © 2017 codesplice. All rights reserved.
//

import LevelDB

struct EncodableDecodableModel {
    let id: Int
    let name: String
}

extension EncodableDecodableModel: Encodable {
    func toData() -> Data {
        let json: [String: Any] = ["id": id, "name": name]

        return try! JSONSerialization
            .data(withJSONObject: json, options: .prettyPrinted)
    }
}

extension EncodableDecodableModel: Decodable {
    init(data: Data) {
        let json = try! JSONSerialization
            .jsonObject(with: data, options: .allowFragments) as! [String: Any]

        id = json["id"] as! Int
        name = json["name"] as! String
    }
}
