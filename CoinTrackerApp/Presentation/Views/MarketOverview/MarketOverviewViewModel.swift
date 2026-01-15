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
    // Current pagination page (CoinGecko markets uses page=1,2,3...)
    private var page: Int = 1

    // Prevents duplicate “load more” calls while one is already running
    @Published private(set) var isLoadingNextPage: Bool = false
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
        page = 1

        // Simulate network latency
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Mock data based on selected category
        let coins: [CoinRowView.CoinModel]
        switch category {
        case .top100:
            coins = (1...20).map { CoinRowView.CoinModel.init(name: "Top Coin \($0)", symbol: "TOP\($0)", iconURL: nil, priceText: "\(100 + $0)", change24hText: "+\(10 + $0)", isUp: true, sparkline: [10.0, 14.5,12.8, 18.2, 16.9, 22.4, 20.7, 26.0]) }
        case .trending:
            coins = (1...20).map { CoinRowView.CoinModel.init(name: "Trending Coin \($0)", symbol: "TREND\($0)", iconURL: nil, priceText: "\(100 + $0)", change24hText: "+\(10 + $0)", isUp: true, sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9]) }
        case .gainers:
            coins = (1...20).map { CoinRowView.CoinModel.init(name: "Gainer Coin \($0)", symbol: "GAIN\($0)", iconURL: nil, priceText: "\(100 + $0)", change24hText: "+\(10 + $0)", isUp: true, sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9]) }
        case .losers:
            coins = (1...20).map { CoinRowView.CoinModel.init(name: "Loser Coin \($0)", symbol: "LOSE\($0)", iconURL: nil, priceText: "\(100 + $0)", change24hText: "-\(10 + $0)", isUp: false, sparkline: [26.0, 22.1, 24.3, 19.5, 21.0, 16.4, 18.2, 12.0]) }
        }

        state = .loaded(coins)
    }
    
    func loadNextPage(category: MarketCategory) async {
        guard category == .top100,
              !isLoadingNextPage,
              case .loaded(let currentCoins) = state else {
                  return
              }
        
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }
        
        page += 1
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let startIndex = (page - 1) * 20 + 1
        
        let newCoins: [CoinRowView.CoinModel] = (startIndex..<(startIndex + 20)).map { i in
            CoinRowView.CoinModel(name: "Top Coin \(i)", symbol: "TOP\(i)", iconURL: nil, priceText: "\(100 + i)", change24hText: "+\(10 + i)", isUp: false, sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9])
        }
        
        state = .loaded(currentCoins + newCoins)
    }
}
