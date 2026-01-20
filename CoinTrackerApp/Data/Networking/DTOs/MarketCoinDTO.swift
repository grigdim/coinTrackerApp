//
//  MarketCoinDTO.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct MarketCoinDTO: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double
    let marketCapRank: Int
    let totalVolume: Double
    let high24h: Double
    let low24h: Double
    let ath: Double
    let atl: Double
    let priceChange24h: Double
    let priceChangePercentage24h: Double
    let marketCapChange24h: Double
    let marketCapchangePercentage24h: Double
}
