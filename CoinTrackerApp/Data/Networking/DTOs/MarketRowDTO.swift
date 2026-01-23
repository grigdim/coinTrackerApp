//
//  MarketRowDTO.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 22/1/26.
//

import Foundation

struct MarketRowDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String?

    let currentPrice: Double?
    let marketCap: Double?
    let totalVolume: Double?
    let circulatingSupply: Double?

    let ath: Double?
    let atl: Double?

    let priceChangePercentage24h: Double?

    let sparklineIn7d: SparklineDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case totalVolume = "total_volume"
        case circulatingSupply = "circulating_supply"
        case ath
        case atl
        case priceChangePercentage24h = "price_change_percentage_24h"
        case sparklineIn7d = "sparkline_in_7d"
    }
}

struct SparklineDTO: Decodable {
    let price: [Double]
}

struct TrendingResponseDTO: Decodable {
    let coins: [TrendingCoinWrapperDTO]
}

struct TrendingCoinWrapperDTO: Decodable {
    let item: TrendingCoinDTO
}

struct TrendingCoinDTO: Decodable {
    let id: String
    let name: String
    let symbol: String
    let large: String?
    let data: TrendingCoinDataDTO?
}

struct TrendingCoinDataDTO: Decodable {
    let price: Double?
    let marketCap: String?
    let totalVolume: String?
    let priceChangePercentage24h: [String: Double]?

    enum CodingKeys: String, CodingKey {
        case price
        case marketCap = "market_cap"
        case totalVolume = "total_volume"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }
}
