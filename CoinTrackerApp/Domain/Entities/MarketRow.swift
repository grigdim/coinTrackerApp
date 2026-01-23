//
//  MarketCoin.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct MarketRow: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String

    let iconURL: URL?

    // UI-formatted values
    let price: String
    let marketCap: String
    let volume: String
    let circulatingSupply: String

    let ath: String
    let atl: String

    let change24h: String
    let change24hRaw: Double
    let isUp: Bool

    let sparkline: [Double]
}
