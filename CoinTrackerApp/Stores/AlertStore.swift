//
//  AlertStore.swift
//  CoinTrackerApp
//
//  Created by vaitsis.vagias on 30/1/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor final class AlertStore: ObservableObject {
    @Published private(set) var active: [CoinPriceAlert] = []
    @Published private(set) var history: [CoinPriceAlert] = []
    // Version to force view refreshes on any mutation
    @Published private(set) var version: Int = 0

    private struct Persisted: Codable, Equatable {
        var active: [CoinPriceAlert]
        var history: [CoinPriceAlert]
    }

    private func loadFromFile() {
        if let decoded = CodablePersistence.loadFromFile(Persisted.self, at: fileURL)
        {
            self.active = decoded.active
            self.history = decoded.history
        } else {
            self.active = []
            self.history = []
        }
        // No need to bump here unless you want refresh at launch. It won't hurt:
        version &+= 1
    }

    private func save() {
        do {
            let payload = Persisted(active: active, history: history)
            try CodablePersistence.saveToFile(payload, at: fileURL)
        } catch {}
        // Saving alone doesn't change state; no bump here.
    }

    func add(_ alert: CoinPriceAlert) {
        // Paranoia: ensure unique id
        if active.contains(where: { $0.id == alert.id }) {
            var newAlert = alert
            newAlert = CoinPriceAlert(
                id: UUID(),
                coinId: alert.coinId,
                targetPrice: alert.targetPrice,
                type: alert.type,
                isEnabled: alert.isEnabled,
                createdAt: alert.createdAt,
                triggeredAt: alert.triggeredAt,
                isUnread: alert.isUnread
            )
            active.append(newAlert)
        } else {
            active.append(alert)
        }
        version &+= 1
        save()
    }

    func delete(_ alert: CoinPriceAlert) {
        if let idx = active.firstIndex(where: { $0.id == alert.id }) {
            active.remove(at: idx)
            version &+= 1
            save()
        }
    }

    func toggleEnabled(alertId: UUID, isEnabled: Bool) {
        guard let idx = active.firstIndex(where: { $0.id == alertId }) else {
            return
        }
        active[idx].isEnabled = isEnabled
        version &+= 1
        save()
    }

    func archiveToHistory(
        alertId: UUID,
        triggeredAt: Date = Date(),
        markUnread: Bool = true
    ) {
        guard let idx = active.firstIndex(where: { $0.id == alertId }) else {
            return
        }
        var alert = active.remove(at: idx)
        alert.triggeredAt = triggeredAt
        alert.isUnread = markUnread
        history.insert(alert, at: 0)
        version &+= 1
        save()
    }

    func evaluateAlerts(
        coinId: String,
        latestPrice: Double,
        baselinePriceForPercentage: Double? = nil
    ) -> [CoinPriceAlert] {
        let candidates = alerts(coinId: coinId).filter { $0.isEnabled }
        return candidates.filter { alert in
            switch alert.type {
            case .above:
                return latestPrice >= alert.targetPrice
            case .below:
                return latestPrice <= alert.targetPrice
            case .percentage:
                guard let base = baselinePriceForPercentage, base > 0 else {
                    return false
                }
                let change = ((latestPrice - base) / base) * 100.0
                return abs(change) >= alert.targetPrice
            }
        }
    }

    func markHistoryRead(alertId: UUID) {
        guard let idx = history.firstIndex(where: { $0.id == alertId }) else {
            return
        }
        history[idx].isUnread = false
        version &+= 1
        save()
    }

    func alerts(coinId: String) -> [CoinPriceAlert] {
        active.filter { $0.coinId == coinId }
    }

    func history(coinId: String) -> [CoinPriceAlert] {
        history.filter { $0.coinId == coinId }
    }

    var unreadHistoryCount: Int {
        history.filter { $0.isUnread }.count
    }

    func unreadHistoryCount(coinId: String) -> Int {
        history(coinId: coinId).filter({ $0.isUnread }).count
    }

    private let fileURL: URL

    init(filename: String = "alerts.json") {
        let fileManager = FileManager.default
        let urls = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        fileURL = urls[0].appendingPathComponent(filename)

        loadFromFile()
    }
}
