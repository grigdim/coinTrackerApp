//
//  WatchlistsViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

//
//  WatchlistsViewModel.swift
//  CoinTrackerApp
//
//  Created by [Your Name]
//

import SwiftUI
import Combine

class WatchlistsViewModel: ObservableObject {
    @Published var watchlists: [Watchlist] = []
    
    init() {
        // Load initial mock data
        self.watchlists = Watchlist.mocks()
    }
    
    // MARK: - Intents
    
    // Reorders the watchlists
    func moveWatchlist(from source: IndexSet, to destination: Int) {
        watchlists.move(fromOffsets: source, toOffset: destination)
        // TODO: Save new order to Core Data
    }
    
    // Deletes a watchlist
    func deleteWatchlist(at offsets: IndexSet) {
        watchlists.remove(atOffsets: offsets)
        // TODO: Remove from Core Data
    }
}
