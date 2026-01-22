//
//  CoineDetailsDTO.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

// Location: Data/DTOs/CoinDetailDTO.swift
struct CoinDetailDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let description: DescriptionDTO
    let links: LinksDTO
    let image: ImageDTO
    let marketData: MarketDataDTO
    
    enum CodingKeys: String, CodingKey {
            case id, symbol, name, description, links, image
            case marketData = "market_data"
        }
}

struct DescriptionDTO: Decodable {
    let en: String?
}

struct LinksDTO: Decodable {
    let homepage: [String]?
    let blockchainSite: [String]?
    let subredditUrl: String?
    
    enum CodingKeys: String, CodingKey {
            case homepage
            case blockchainSite = "blockchain_site"
            case subredditUrl = "subreddit_url"
        }

}

struct ImageDTO: Decodable {
    let thumb: String?
    let small: String?
    let large: String?
}

struct MarketDataDTO: Decodable {
    let currentPrice: [String: Double]?
    let marketCap: [String: Double]?
    let totalVolume: [String: Double]?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    
    
    
    // All-Time High/Low
    let ath: [String: Double]?
    let atl: [String: Double]?
    
    // Price Change Statistics
    let priceChange24h: Double?
    let priceChangePercentage24h: Double?
    let priceChangePercentage7d: Double?
    let priceChangePercentage30d: Double?
    let priceChangePercentage1y: Double?
    
    enum CodingKeys: String, CodingKey {
            case currentPrice = "current_price"
            case marketCap = "market_cap"
            case totalVolume = "total_volume"
            case circulatingSupply = "circulating_supply"
            case totalSupply = "total_supply"
            case maxSupply = "max_supply"
            case ath, atl
            case priceChange24h = "price_change_24h"
            case priceChangePercentage24h = "price_change_percentage_24h"
            case priceChangePercentage7d = "price_change_percentage_7d"
            case priceChangePercentage30d = "price_change_percentage_30d"
            case priceChangePercentage1y = "price_change_percentage_1y"
        }

}
