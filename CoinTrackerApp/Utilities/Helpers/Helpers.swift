//
//  Helpers.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 23/1/26.
//

import Foundation

func isStale(_ fetchedAt: Date, cacheTTL: TimeInterval) -> Bool {
    Date().timeIntervalSince(fetchedAt) > cacheTTL
}

struct Cached<Value> {
    let value: Value
    let fetchedAt: Date
}

func alertTitle(for alert: CoinPriceAlert) -> String {
    switch alert.type {
    case .above:
        return "Price above \(CurrencyFormatter.usd(alert.targetPrice))"
    case .below:
        return "Price below \(CurrencyFormatter.usd(alert.targetPrice))"
    case .percentage:
        return "Change ±\(PercentFormatter.twoDecimals(alert.targetPrice))"
    }
}

func alertSubtitle(for alert: CoinPriceAlert) -> String {
    var parts: [String] = []
    parts.append(
        "Created "
            + alert.createdAt.formatted(
                date: .abbreviated,
                time: .shortened
            )
    )
    if alert.isEnabled == false {
        parts.append("Disabled")
    }
    return parts.joined(separator: " • ")
}
