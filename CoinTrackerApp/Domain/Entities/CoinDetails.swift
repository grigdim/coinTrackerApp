//
//  CoinDetails.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct CoinDetails: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String

    // Images
    let iconURL: URL?

    // Price info (already formatted for UI)
    let price: String
    let change24h: String
    let isUp: Bool

    // Market stats
    let marketCap: String
    let volume: String
    let circulatingSupply: String
    let ath: String
    let atl: String

    // Chart
    let sparkline: [Double]   // from history endpoint

    // About
    let description: String?

    // Links (UI-friendly)
    let websiteURL: URL?
    let explorerURL: URL?
    let subredditURL: URL?
}
