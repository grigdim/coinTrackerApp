//
//  WatchlistsViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI
import Combine

class WatchlistsViewModel: ObservableObject {
    @Published var watchlists: [Watchlist] = []
    
    init() {}
    
    func loadData() {
        guard watchlists.isEmpty else { return }
        
        self.watchlists = Watchlist.mocks()
    }
    
    // MARK: - Watchlist Management
    
    func deleteWatchlist(at offsets: IndexSet) {
        watchlists.remove(atOffsets: offsets)
    }
    
    func moveWatchlist(from source: IndexSet, to destination: Int) {
        watchlists.move(fromOffsets: source, toOffset: destination)
    }
}
