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
    private let cacheTTL: TimeInterval = 30

    private var refreshTask: Task<Void, Never>?
    private var cachedChartData:
        [String: [ChartRange: Cached<[CoinChartPoint]>]] = [:]

    init(getChartData: GetChartDataUseCase) {
        self.getChartData = getChartData
    }

    func loadChartRange(for id: String, range: ChartRange) async {
        activeCoinId = id
        activeChartRange = range

        // 1) Serve cached immediately (good UX)
        if let cached = cachedChartData[id]?[range] {
            state = .loaded(cached.value)

            // If fresh, stop here
            if !isStale(cached.fetchedAt, cacheTTL: cacheTTL) {
                return
            }
            // else: fall through to refresh in background
        } else {
            // No cache at all -> show full loading
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
