//
//  PortfolioViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Combine
import SwiftUI

@MainActor
class PortfolioViewModel: ObservableObject {

    // MARK: - 1. Portfolio State (User's Assets)
    @Published var assets: [PortfolioAsset] = [] {
        didSet { savePortfolio() }
    }
    @Published var portfolioState: ViewState<Void> = .idle

    // MARK: - 2. Search/Selection State (Market Data)
    // Stores the list of all coins for the "Add Asset" screen
    @Published var availableCoins: [MarketRow] = []
    @Published var searchState: ViewState<Void> = .idle
    @Published var searchText: String = ""

    // Filter logic for the search bar
    var filteredCoins: [MarketRow] {
        guard !searchText.isEmpty else { return availableCoins }
        return availableCoins.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Dependencies & Keys
    private let repository: MarketRowRepository
    private let portfolioSaveKey = "saved_portfolio"
    private let coinListSaveKey = "cached_coin_list"  // New key for offline search

    // MARK: - Initialization
    init(repository: MarketRowRepository) {
        self.repository = repository
        loadPortfolio()
    }

    // MARK: - Feature 1: Refresh Portfolio Prices
    func refreshPortfolioPrices() async {
        guard !assets.isEmpty else { return }

        portfolioState = .loading
        let userCoinIds = assets.map { $0.id }

        do {
            let marketRows = try await repository.fetchMarketRows(
                category: "layer-1",
                perPage: 250,
                page: 1,
                ids: userCoinIds
            )

            // Map ID -> Raw Price
            let priceMap = Dictionary(
                uniqueKeysWithValues: marketRows.map {
                    ($0.id, $0.currentPriceRaw)
                }
            )

            var updatedAssets = assets
            for i in 0..<updatedAssets.count {
                let assetId = updatedAssets[i].id

                // SAFETY: Only update if price exists and is > 0
                if let livePrice = priceMap[assetId], livePrice > 0 {
                    updatedAssets[i].lastKnownPrice = livePrice
                }
            }

            self.assets = updatedAssets
            portfolioState = .loaded(())

        } catch {
            print("Portfolio refresh failed: \(error)")
            // Keep showing old data on failure
            portfolioState = .failed(error)
        }
    }

    // MARK: - Feature 2: Load Coin List (Offline Capable)
    func loadAvailableCoins() async {
        // A. If already loaded in memory, stop.
        guard availableCoins.isEmpty else { return }

        // B. Try to load from DISK first (Instant offline access)
        loadCachedCoinList()

        if !availableCoins.isEmpty {
            // We have offline data, show it immediately
            searchState = .loaded(())
        } else {
            // No cache, show loading spinner
            searchState = .loading
        }

        do {
            // C. Try Network Call to update data
            let rows = try await repository.fetchMarketRows(
                category: "layer-1",
                perPage: 100,
                page: 1,
                ids: nil
            )

            // D. Success: Update Memory & Save to Disk
            self.availableCoins = rows
            self.saveCoinList()
            searchState = .loaded(())

        } catch {
            print("Failed to fetch fresh coin list: \(error)")

            // E. Failure: Only show error if we have NO cached data
            if availableCoins.isEmpty {
                searchState = .failed(error)
            }
        }
    }

    // MARK: - Actions (CRUD)
    func addTransaction(coin: CoinDetailsRoute, price: Double, quantity: Double)
    {
        let transaction = PortfolioTransaction(
            id: UUID(),
            date: Date(),
            pricePerCoin: price,
            quantity: quantity
        )

        if let index = assets.firstIndex(where: { $0.id == coin.id }) {
            assets[index].transactions.append(transaction)
        } else {
            let newAsset = PortfolioAsset(
                id: coin.id,
                symbol: coin.name,
                lastKnownPrice: price,  // Use buy price initially
                transactions: [transaction]
            )
            assets.append(newAsset)
        }
    }

    func deleteAsset(at offsets: IndexSet) {
        assets.remove(atOffsets: offsets)
    }

    func resetPortfolio() {
        UserDefaults.standard.removeObject(forKey: portfolioSaveKey)
        self.assets = []
    }

    // MARK: - Computed Totals
    var totalValue: Double {
        assets.reduce(0) { $0 + $1.currentValue }
    }

    var totalProfitLoss: Double {
        assets.reduce(0) { $0 + $1.profitLoss }
    }

    var totalProfitLossPercentage: Double {
        let cost = assets.reduce(0) { $0 + $1.totalCostBasis }
        guard cost > 0 else { return 0 }
        return (totalProfitLoss / cost) * 100
    }

    // MARK: - Persistence Helpers

    private func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(assets) {
            UserDefaults.standard.set(encoded, forKey: portfolioSaveKey)
        }
    }

    private func loadPortfolio() {
        if let data = UserDefaults.standard.data(forKey: portfolioSaveKey),
            let decoded = try? JSONDecoder().decode(
                [PortfolioAsset].self,
                from: data
            )
        {
            self.assets = decoded
        }
    }

    private func saveCoinList() {
        if let encoded = try? JSONEncoder().encode(availableCoins) {
            UserDefaults.standard.set(encoded, forKey: coinListSaveKey)
        }
    }

    private func loadCachedCoinList() {
        if let data = UserDefaults.standard.data(forKey: coinListSaveKey),
            let decoded = try? JSONDecoder().decode(
                [MarketRow].self,
                from: data
            )
        {
            self.availableCoins = decoded
        }
    }
}
