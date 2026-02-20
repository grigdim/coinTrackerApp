//
//  Watchlist.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct Watchlist: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var coinIDs: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case coinIDs
        case coins // Legacy key (array of CoinDetails snapshots)
    }

    init(id: UUID, name: String, icon: String, coinIDs: [String]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.coinIDs = coinIDs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)

        if let ids = try container.decodeIfPresent([String].self, forKey: .coinIDs) {
            coinIDs = ids.uniquedPreservingOrder()
            return
        }

        if let legacyCoins = try container.decodeIfPresent([CoinDetails].self, forKey: .coins) {
            coinIDs = legacyCoins.map(\.id).uniquedPreservingOrder()
            return
        }

        coinIDs = []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(coinIDs.uniquedPreservingOrder(), forKey: .coinIDs)
    }
    
    // Mock Data
        static func mocks() -> [Watchlist] {
            // Hardcoded UUIDs for consistent testing/previews
            let uuid1 = UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!
            let uuid2 = UUID(uuidString: "12345678-90AB-CDEF-1234-567890ABCDEF")!
            
            return [
                Watchlist(
                    id: uuid1,
                    name: "My Favorites",
                    icon: "star.fill",
                    coinIDs: ["bitcoin"]
                ),
                Watchlist(id: uuid2, name: "DeFi", icon: "flame.fill", coinIDs: [])
            ]
        }
}

private extension Array where Element: Hashable {
    func uniquedPreservingOrder() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}
