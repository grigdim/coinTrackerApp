//
//  AddToWatchlistView.swift
//  CoinTrackerApp
//
//  Created by antonis.darmis on 28/1/26.
//

import SwiftUI

struct AddToWatchlistView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WatchlistsViewModel
    let coin: CoinDetails
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.watchlists) { watchlist in
                    Button {
                        addToWatchlist(watchlist)
                    } label: {
                        HStack {
                            ZStack {
                                Circle().fill(Color.blue.opacity(0.1)).frame(width: 32, height: 32)
                                Image(systemName: watchlist.icon).foregroundColor(.blue).font(.caption)
                            }
                            Text(watchlist.name).foregroundColor(.primary)
                            Spacer()
                            
                            // Check if coin is already in this list
                            if watchlist.coinIDs.contains(coin.id) {
                                Image(systemName: "checkmark").foregroundColor(.secondary)
                            } else {
                                Image(systemName: "plus").foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Add to Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addToWatchlist(_ targetList: Watchlist) {
        // Find the index of the selected watchlist
        if let index = viewModel.watchlists.firstIndex(where: { $0.id == targetList.id }) {
            var updatedList = viewModel.watchlists[index]
            
            // Avoid duplicates
            if !updatedList.coinIDs.contains(coin.id) {
                updatedList.coinIDs.append(coin.id)
                viewModel.watchlists[index] = updatedList // This triggers the save in ViewModel
            }
        }
        dismiss()
    }
}

