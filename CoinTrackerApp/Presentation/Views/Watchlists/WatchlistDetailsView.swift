import SwiftUI

//
//  WatchlistDetailView.swift
//  CoinTrackerApp
//
//  Created by [Your Name]
//

import SwiftUI

struct WatchlistDetailView: View {
    let watchlist: Watchlist
    
    var body: some View {
        Group {
            if watchlist.coins.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(watchlist.coins) { coin in
                        CoinRowView(coin: coin)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            
                            // Swipe to Add to Portfolio
                            .swipeActions(edge: .leading) {
                                Button {
                                    print("Added \(coin.name) to portfolio")
                                } label: {
                                    Label("Portfolio", systemImage: "case.fill")
                                }
                                .tint(.blue)
                            }
                            
                            // Swipe to Remove Coin from this specific watchlist
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    print("Removed \(coin.name)")
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(watchlist.name)
    }
}




#Preview {
    NavigationStack {
        WatchlistDetailView(watchlist: Watchlist.mocks()[0])
    }
}
