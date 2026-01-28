//
//  WatchlistDetailView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct WatchlistDetailView: View {
    @Binding var watchlist: Watchlist
    
    var body: some View {
        Group {
            if watchlist.coins.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(watchlist.coins) { coinDetail in
                        CoinRowView(coin: coinDetail.toMarketRow)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            
                            // Swipe Leading: Portfolio
                            .swipeActions(edge: .leading) {
                                Button {
                                    print("Portfolio: \(coinDetail.name)")
                                } label: {
                                    Label("Portfolio", systemImage: "case.fill")
                                }
                                .tint(.blue)
                            }
                            
                            // Swipe Trailing: Delete
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteCoin(coinDetail)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                            // Navigation Link (Invisible)
                            .background(
                                NavigationLink("", value: coinDetail)
                                    .opacity(0)
                            )
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(watchlist.name)
        .navigationDestination(for: CoinDetails.self) { coin in
            // Map 'CoinDetails' -> 'CoinDetailsRoute'
            CoinDetailsView(
                route: CoinDetailsRoute(
                    id: coin.id,
                    name: coin.name,
                    iconURL: coin.iconURL
                )
            )
        }
    }
    
    private func deleteCoin(_ coin: CoinDetails) {
        if let index = watchlist.coins.firstIndex(where: { $0.id == coin.id }) {
            watchlist.coins.remove(at: index)
        }
    }
}

// Helper for the preview
#Preview {
    NavigationStack {
        WatchlistDetailView(watchlist: .constant(Watchlist.mocks()[0]))
    }
}
