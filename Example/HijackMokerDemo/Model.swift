//
//  PoketModel.swift
//  HijackMokerDemo
//
//  Created by 영호 박 on 8/1/24.
//

import Foundation

struct PoketMons: Codable {
    var results: [PoketMon]
}

struct PoketMon: Codable {
    var name: String
    var imageUrl: String {
        "https://img.pokemondb.net/artwork/\(name).jpg"
    }
}
