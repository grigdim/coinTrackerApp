//
//  PortfolioViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI
import Combine

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
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Dependencies & Keys
    private let repository: MarketRowRepository
    private let portfolioSaveKey = "saved_portfolio"
    private let coinListSaveKey = "cached_coin_list" // Key for offline search list
    
    // MARK: - Initialization
    init(repository: MarketRowRepository) {
        self.repository = repository
        loadPortfolio()
    }
    
    // MARK: - Feature 1: Refresh Portfolio Prices
    func refreshPortfolioPrices() async {
        guard !assets.isEmpty else {
            portfolioState = .loaded(())
            return
        }
        
        portfolioState = .loading
        let userCoinIds = assets.map { $0.id }
        
        do {
            // Fetch by ids only. Keep category empty so endpoint omits it.
            let marketRows = try await repository.fetchMarketRows(
                category: "",
                perPage: 250,
                page: 1,
                ids: userCoinIds
            )
            
            // Map ID -> Raw Price
            // We use a safe dictionary map
            let priceMap = Dictionary(uniqueKeysWithValues: marketRows.map {
                ($0.id, $0.currentPriceRaw)
            })
            
            var updatedAssets = assets
            for i in 0..<updatedAssets.count {
                let assetId = updatedAssets[i].id
                
                // Only update if we got a valid price back
                if let livePrice = priceMap[assetId], livePrice > 0 {
                    updatedAssets[i].lastKnownPrice = livePrice
                }
            }
            
            self.assets = updatedAssets
            portfolioState = .loaded(())
            
        } catch {
            // Keep showing old data on failure, but mark state as failed
            portfolioState = .failed(error)
        }
    }
    
    // MARK: - Feature 2: Load Coin List (Offline Capable)
    func loadAvailableCoins() async {
        guard availableCoins.isEmpty else { return }
        
        // 1. Try to load from DISK first (Instant offline access)
        loadCachedCoinList()
        
        if !availableCoins.isEmpty {
            searchState = .loaded(())
        } else {
            searchState = .loading
        }
        
        do {
            // 2. Try Network Call
            let rows = try await repository.fetchMarketRows(
                category: "layer-1",
                perPage: 100,
                page: 1,
                ids: nil
            )
            
            // 3. Success: Update Memory & Save to Disk
            self.availableCoins = rows
            self.saveCoinList()
            searchState = .loaded(())
            
        } catch {
            if availableCoins.isEmpty {
                searchState = .failed(error)
            }
        }
    }

    func fetchRowsForCoinIDs(_ ids: [String]) async throws -> [MarketRow] {
        let uniqueIDs = ids.orderedUniqueElements()
        guard !uniqueIDs.isEmpty else { return [] }

        let batchSize = 250
        var allRows: [MarketRow] = []
        var index = 0

        while index < uniqueIDs.count {
            let end = min(index + batchSize, uniqueIDs.count)
            let batch = Array(uniqueIDs[index..<end])
            let rows = try await repository.fetchMarketRows(
                category: "",
                perPage: batch.count,
                page: 1,
                ids: batch
            )
            allRows.append(contentsOf: rows)
            index = end
        }

        return allRows
    }
    
    // MARK: - Actions (CRUD)
    
    func addTransaction(coin: CoinDetailsRoute, price: Double, quantity: Double) {
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
                symbol: coin.symbol,
                lastKnownPrice: price, // Use input price initially
                transactions: [transaction]
            )
            assets.append(newAsset)
        }
        
        // Force save immediately
        savePortfolio()
        
        // FIX: Trigger a live price update immediately
        // This ensures the user sees the real market value, not just their manual entry.
        Task {
            await refreshPortfolioPrices()
        }
    }
    
    func deleteAsset(at offsets: IndexSet) {
        assets.remove(atOffsets: offsets)
    }
    
    func resetPortfolio() {
        CodablePersistence.removeUserDefaultsValue(for: portfolioSaveKey)
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
        CodablePersistence.saveToUserDefaults(assets, key: portfolioSaveKey)
    }
    
    private func loadPortfolio() {
        if let decoded = CodablePersistence.loadFromUserDefaults(
            [PortfolioAsset].self,
            key: portfolioSaveKey
        ) {
            self.assets = decoded
        }
    }
    
    private func saveCoinList() {
        CodablePersistence.saveToUserDefaults(availableCoins, key: coinListSaveKey)
    }
    
    private func loadCachedCoinList() {
        if let decoded = CodablePersistence.loadFromUserDefaults(
            [MarketRow].self,
            key: coinListSaveKey
        ) {
            self.availableCoins = decoded
        }
    }
}

private extension Array where Element: Hashable {
    func orderedUniqueElements() -> [Element] {
        var seen: Set<Element> = []
        var result: [Element] = []
        for element in self where seen.insert(element).inserted {
            result.append(element)
        }
        return result
    }
}
