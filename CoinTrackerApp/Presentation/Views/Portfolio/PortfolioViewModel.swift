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
    @Published var assets: [PortfolioAsset] = [] {
        didSet { savePortfolio() }
    }
    
    @Published var state: ViewState<Void> = .idle
    
    private let repository: MarketRowRepository
    private let saveKey = "saved_portfolio"
    
    init(repository: MarketRowRepository) {
        self.repository = repository
        loadPortfolio()
    }
    
    // MARK: - Live Data Fetching
    
    // In PortfolioViewModel.swift

    func refreshPortfolioPrices() async {
        guard !assets.isEmpty else {
            state = .loaded(())
            return
        }

        state = .loading
        let userCoinIds = assets.map { $0.id }
        
        do {
            let marketRows = try await repository.fetchMarketRows(
                category: .top100,
                perPage: 250,
                page: 1,
                ids: userCoinIds,
            )
            
            let priceMap = Dictionary(uniqueKeysWithValues: marketRows.map {
                ($0.id, $0.price.asCurrencyDouble)
            })
            
            var updatedAssets = assets
            for i in 0..<updatedAssets.count {
                let assetId = updatedAssets[i].id
                if let livePrice = priceMap[assetId], livePrice > 0 {
                    updatedAssets[i].lastKnownPrice = livePrice
                }
            }
            
            self.assets = updatedAssets
            state = .loaded(())
            
        } catch {
            print("Portfolio fetch failed: \(error)")
            state = .failed(error)
        }
    }
    
    // MARK: - Actions
    
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
                symbol: coin.name,
                lastKnownPrice: price, // Initialize with buy price as fallback
                transactions: [transaction]
            )
            assets.append(newAsset)
        }
    }
    
    func deleteAsset(at offsets: IndexSet) {
        assets.remove(atOffsets: offsets)
    }
    
    // MARK: - Computed Totals
    
    var totalValue: Double {
        assets.reduce(0) { $0 + $1.currentValue }
    }
    
    var totalProfitLoss: Double {
        assets.reduce(0) { $0 + $1.profitLoss }
    }
    
    var totalProfitLossPercentage: Double {
        let totalCost = assets.reduce(0) { $0 + $1.totalCostBasis }
        guard totalCost > 0 else { return 0 }
        return (totalProfitLoss / totalCost) * 100
    }
    
    // MARK: - Persistence
    
    private func savePortfolio() {
        if let encoded = try? JSONEncoder().encode(assets) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadPortfolio() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([PortfolioAsset].self, from: data) {
            self.assets = decoded
        }
    }
}
