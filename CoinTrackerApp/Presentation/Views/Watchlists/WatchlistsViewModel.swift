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
        // 3. Try to load from UserDefaults first
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Watchlist].self, from: data) {
                self.watchlists = decoded
                return
            }
        }
        // 4. If no saved data exists (First launch), load mocks
        //TODO REMOVE 
        self.watchlists = Watchlist.mocks()
    }
    
    // 5. Save Helper
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(watchlists) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
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
