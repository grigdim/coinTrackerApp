//
//  PriceChartViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 22/1/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class PriceChartViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[CoinChartPoint]> = .idle

    private var activeCoinId: String?
    private var activeChartRange: ChartRange = .day

    private let getChartData: GetChartDataUseCase
    private let alertStore: AlertStore
    private let cacheTTL: TimeInterval = 30

    private var refreshTask: Task<Void, Never>?
    private var cachedChartData:
        [String: [ChartRange: Cached<[CoinChartPoint]>]] = [:]

    init(getChartData: GetChartDataUseCase, alertStore: AlertStore) {
        self.getChartData = getChartData
        self.alertStore = alertStore
    }

    func loadChartRange(for id: String, range: ChartRange) async {
        activeCoinId = id
        activeChartRange = range

        if let cached = cachedChartData[id]?[range] {
            state = .loaded(cached.value)

            if !isStale(cached.fetchedAt, cacheTTL: cacheTTL) {
                return
            }
        } else {
            state = .loading
        }

        await refreshChartData(for: id, range: range)
    }

    func refreshChartData(for id: String, range: ChartRange) async {
        activeCoinId = id
        activeChartRange = range

        refreshTask?.cancel()

        refreshTask = Task {
            do {
                let chartData = try await getChartData.execute(
                    coinId: id,
                    range: range
                )

                guard !Task.isCancelled else { return }
                guard self.activeCoinId == id, self.activeChartRange == range
                else { return }

                self.cachedChartData[id, default: [:]][range] = Cached(
                    value: chartData,
                    fetchedAt: .now
                )
                self.state = .loaded(chartData)

                // Evaluate alerts and schedule notifications
                if let latestPrice = chartData.last?.value {
                    let baseline = chartData.first?.value
                    let triggered = self.alertStore.evaluateAlerts(
                        coinId: id,
                        latestPrice: latestPrice,
                        baselinePriceForPercentage: baseline
                    )
                    for alert in triggered {
                        NotificationManager.shared.schedulePriceAlertNotification(
                            alert: alert,
                            latestPrice: latestPrice
                        )
                    }
                }

            } catch {
                guard !Task.isCancelled else { return }
                guard self.activeCoinId == id, self.activeChartRange == range
                else { return }

                // Only fallback if we have cached data for this range
                if let cached = self.cachedChartData[id]?[range] {
                    self.state = .loaded(cached.value)
                } else {
                    self.state = .failed(error)
                }
            }
        }

        await refreshTask?.value
    }
    
    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    var points: [CoinChartPoint] {
        if case .loaded(let pts) = state { return pts }
        return []
    }
}
