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

    private struct Persisted: Codable, Equatable {
        var active: [CoinPriceAlert]
        var history: [CoinPriceAlert]
    }

    private func loadFromFile() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(Persisted.self, from: data)
            self.active = decoded.active
            self.history = decoded.history
        } catch {
            self.active = []
            self.history = []
        }
    }

    private func save() {
        do {
            let payload = Persisted(active: active, history: history)
            let data = try JSONEncoder().encode(payload)
            try data.write(to: fileURL, options: [.atomic])

        } catch {
            print("Failed to save alerts: \(error)")
        }
    }

    func add(_ alert: CoinPriceAlert) {
        active.append(alert)
        save()
    }

    func delete(_ alert: CoinPriceAlert) {
        if let idx = active.firstIndex(where: { $0.id == alert.id }) {
            active.remove(at: idx)
            save()
        }
    }

    func toggleEnabled(alertId: UUID, isEnabled: Bool) {
        guard let idx = active.firstIndex(where: { $0.id == alertId }) else {
            return
        }
        active[idx].isEnabled = isEnabled
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

                // Treat targetPrice as magnitude threshold (e.g., 5 means ±5%)

                return abs(change) >= alert.targetPrice

            }

        }

    }

    func markHistoryRead(alertId: UUID) {
        guard let idx = history.firstIndex(where: { $0.id == alertId }) else {
            return
        }
        history[idx].isUnread = false
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
