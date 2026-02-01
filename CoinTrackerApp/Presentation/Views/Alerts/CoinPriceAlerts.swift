//
//  CoinPriceAlerts.swift
//  CoinTrackerApp
//
//  Created by vaitsis.vagias on 30/1/26.
//
import Foundation

struct CoinPriceAlert: Identifiable, Codable, Equatable {
    let id: UUID
    let coinId: String
    var targetPrice: Double
    var type: AlertType
    var isEnabled: Bool
    let createdAt: Date
    var triggeredAt: Date?
    var isUnread: Bool
}
