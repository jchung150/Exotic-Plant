//
//  File.swift
//  ExoticPlant
//
//  Created by Kyoungran Park on 2024-11-05.
//

import Foundation

struct ExoticPlant: Identifiable, Codable, Hashable {
    var id: Int
    var name: String
    var description: String?
    var countries: String?
    var image: String? // Base64 encoded string
}
