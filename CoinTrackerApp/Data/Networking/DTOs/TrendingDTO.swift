//
//  TrendingDTO.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct TrendingDTO: Codable {
    let coins: [TrendingCoinDataDTO]
}

struct TrendingCoinDataDTO: Codable {
    let item: TrendingCoinDTO
}

struct TrendingCoinDTO: Codable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int
    let thumb: String
    let large: String
    
    enum CodingKeys: String, CodingKey {
            case id, name, symbol, thumb, large
            case marketCapRank = "market_cap_rank"
        }

}
