//
//  WatchlistsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

// MARK: - Watchlist Model (The struct you asked for)
struct Watchlist: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String // SF Symbol name
    var coins: [CoinDetails]
    
    // Mock Data Generator
    static func mocks() -> [Watchlist] {
        [
            Watchlist(id: UUID(), name: "My Favorites", icon: "star.fill", coins: [
                CoinDetails(id: "btc", name: "Bitcoin", symbol: "BTC", iconURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"), price: "$43,210.00", marketCap: "850B", volume: "30B", circulatingSupply: "19M", ath: "69k", atl: "67", change24h: "+2.5%", isUp: true, sparkline: [40, 41, 42, 43]),
                CoinDetails(id: "eth", name: "Ethereum", symbol: "ETH", iconURL: URL(string: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"), price: "$2,300.00", marketCap: "280B", volume: "15B", circulatingSupply: "120M", ath: "4.8k", atl: "0.4", change24h: "-1.2%", isUp: false, sparkline: [24, 23.5, 23, 23.2])
            ]),
            Watchlist(id: UUID(), name: "DeFi Gems", icon: "flame.fill", coins: [
                CoinDetails(id: "uni", name: "Uniswap", symbol: "UNI", iconURL: nil, price: "$6.50", marketCap: "4B", volume: "200M", circulatingSupply: "600M", ath: "44", atl: "1", change24h: "+5.0%", isUp: true, sparkline: [6, 6.1, 6.3, 6.5])
            ]),
            Watchlist(id: UUID(), name: "High Risk", icon: "exclamationmark.triangle.fill", coins: [])
        ]
    }
}

struct WatchlistView: View {
    @StateObject private var viewModel = WatchlistsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.watchlists) { watchlist in
                    NavigationLink(value: watchlist) {
                        HStack {
                            Image(systemName: watchlist.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading) {
                                Text(watchlist.name)
                                    .font(.headline)
                                Text("\(watchlist.coins.count) coins")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let index = viewModel.watchlists.firstIndex(of: watchlist) {
                                viewModel.deleteWatchlist(at: IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: viewModel.moveWatchlist)
                .onDelete(perform: viewModel.deleteWatchlist)
            }
            .listStyle(.sidebar)
            .navigationTitle("My Watchlists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton() // <--- The magic button that shows the drag handles
                }
            }
            // Navigate to the detail view when a row is tapped
            .navigationDestination(for: Watchlist.self) { watchlist in
                WatchlistDetailView(watchlist: watchlist)
            }
        }
    }
}

#Preview {
    WatchlistView()
}
