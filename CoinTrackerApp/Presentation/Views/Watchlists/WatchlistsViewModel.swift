//
//  WatchlistsViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI
import Combine

class WatchlistsViewModel: ObservableObject {
    
    // 1. Key for UserDefaults
    private let saveKey = "saved_watchlists"
    
    // 2. Observer: Automatically save whenever the list changes
    @Published var watchlists: [Watchlist] = [] {
        didSet {
            saveData()
        }
    }
    
    init() {}
    
    func loadData() {
        if let decoded = CodablePersistence.loadFromUserDefaults(
            [Watchlist].self,
            key: saveKey
        ) {
            self.watchlists = decoded
            return
        }

        // If no saved data exists (first launch), start empty.
        self.watchlists = []
    }
    
    private func saveData() {
        CodablePersistence.saveToUserDefaults(watchlists, key: saveKey)
    }
    
    // MARK: - Watchlist Management
    
    func deleteWatchlist(at offsets: IndexSet) {
        watchlists.remove(atOffsets: offsets)
    }
    
    func addWatchlist(name: String, icon: String) {
        let newWatchlist = Watchlist(
            id: UUID(),
            name: name,
            icon: icon,
            coins: []
        )
        watchlists.append(newWatchlist)
    }
    
    func moveWatchlist(from source: IndexSet, to destination: Int) {
        watchlists.move(fromOffsets: source, toOffset: destination)
    }
}
