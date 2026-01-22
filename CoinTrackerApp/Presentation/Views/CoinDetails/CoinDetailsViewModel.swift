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
    @Published private(set) var state: ViewState<CoinDetails> = .idle
    private var activeChartRange: ChartRange = .day
    private let getCoinDetail: GetCoinDetailUseCase

    init(getCoinDetail: GetCoinDetailUseCase) {
        self.getCoinDetail = getCoinDetail
    }

    func load(id: String) async {
        state = .loading
        do {
            let coin = try await getCoinDetail.execute(id: id)
            state = .loaded(coin)
        } catch {
            state = .failed(error)
        }
    }
    
    func loadChart(chartRange: ChartRange) {
        activeChartRange = chartRange
    }
}
