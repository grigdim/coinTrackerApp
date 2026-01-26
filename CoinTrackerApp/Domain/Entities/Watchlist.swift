//
//  Watchlist.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct Watchlist: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    
    var coins: [CoinDetails]
    
    // Mock Data
    static func mocks() -> [Watchlist] {
        [
            Watchlist(id: UUID(), name: "My Favorites", icon: "star.fill", coins: [
                CoinDetails(
                    id: "btc", name: "Bitcoin", symbol: "BTC",
                    iconURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
                    price: "$43,210.12", change24h: "+2.45%", isUp: true,
                    marketCap: "$850B", volume: "$25B", circulatingSupply: "19M",
                    ath: "$69,000", atl: "$65",
                    sparkline: [40000, 41000, 42000, 43210],
                    description: "Digital Gold", websiteURL: nil, explorerURL: nil, subredditURL: nil
                )
            ]),
            Watchlist(id: UUID(), name: "DeFi", icon: "flame.fill", coins: [])
        ]
    }
}
