//
//  CategoryDTO.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 31/1/26.
//

import Foundation

struct CategoryDTO: Decodable {
    let categoryId: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case name
    }
}
