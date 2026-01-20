//
//  CoinDetailsViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation
import Combine

@MainActor
final class CoinDetailsViewModel: ObservableObject {
    // Published UI state must live inside the class
    @Published private(set) var state: ViewState<ChartRange> = .idle
    private(set) var activeChartRange: ChartRange = .day

    func load(for selectedChartRange: ChartRange) {
        activeChartRange = selectedChartRange
        // Update state as needed for the selected range
        // e.g., state = .loading or trigger a fetch
    }
}
