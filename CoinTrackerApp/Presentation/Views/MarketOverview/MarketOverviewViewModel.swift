//
//  MarketOverviewViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Combine
import Foundation

@MainActor
final class MarketOverviewViewModel: ObservableObject {

    /// The view reads this to decide what to display.
    @Published private(set) var state: ViewState<[CoinRowView.CoinModel]> = .idle

    /// Called the first time the screen appears.
    func load(category: MarketCategory) async {
        // Avoid re-loading if we already have data (simple demo behavior).
        if case .loaded = state { return }
        await refresh(category: category)
    }

    /// Called when the user refreshes or changes category.
    func refresh(category: MarketCategory) async {
        state = .loading

        // Simulate network latency
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Mock data based on selected category
        let coins: [CoinRowView.CoinModel]
        switch category {
        case .top100:
            coins = (1...20).map { CoinRowView.CoinModel.init(name: "Top Coin \($0)", symbol: "TOP\($0)", iconURL: nil, priceText: "\(100 + $0)", change24hText: "+\(10 + $0)", isUp: true) }
        case .trending:
            coins = (1...20).map { CoinRowView.CoinModel.init(name: "Trending Coin \($0)", symbol: "TREND\($0)", iconURL: nil, priceText: "\(100 + $0)", change24hText: "+\(10 + $0)", isUp: true) }
        case .gainers:
            coins = (1...20).map { CoinRowView.CoinModel.init(name: "Gainer Coin \($0)", symbol: "GAIN\($0)", iconURL: nil, priceText: "\(100 + $0)", change24hText: "+\(10 + $0)", isUp: true) }
        case .losers:
            coins = (1...20).map { CoinRowView.CoinModel.init(name: "Loser Coin \($0)", symbol: "LOSE\($0)", iconURL: nil, priceText: "\(100 + $0)", change24hText: "-\(10 + $0)", isUp: false) }
        }

        state = .loaded(coins)
    }
}
