//
//  PortfolioModels.swift
//  CoinTrackerApp
//
//  Created by antonis.darmis on 30/1/26.
//

import Foundation

struct PortfolioTransaction: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let pricePerCoin: Double
    let quantity: Double
    
    var totalCost: Double { pricePerCoin * quantity }
}

struct PortfolioAsset: Identifiable, Codable, Hashable {
    let id: String           // e.g., "bitcoin"
    let symbol: String       // e.g., "btc"
    var lastKnownPrice: Double? // Cache price here for offline viewing/profit calc
    var transactions: [PortfolioTransaction]
    
    var totalQuantity: Double {
        transactions.reduce(0) { $0 + $1.quantity }
    }
    
    var totalCostBasis: Double {
        transactions.reduce(0) { $0 + $1.totalCost }
    }
    
    var currentValue: Double {
        (lastKnownPrice ?? 0) * totalQuantity
    }
    
    var profitLoss: Double {
        currentValue - totalCostBasis
    }
}
