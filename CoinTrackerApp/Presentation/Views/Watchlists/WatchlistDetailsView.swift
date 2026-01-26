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
                    ForEach(watchlist.coins) { coinDetail in
                        CoinRowView(coin: coinDetail.toMarketRow)
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .leading) {
                                Button {
                                    print("Portfolio: \(coinDetail.name)")
                                } label: {
                                    Label("Portfolio", systemImage: "case.fill")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    print("Delete: \(coinDetail.name)")
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
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
            Text("Detail Screen for \(coin.name)") // Place your CoinDetailView here
        }
    }
}
    
    
    
    
    #Preview {
        NavigationStack {
            WatchlistDetailView(watchlist: Watchlist.mocks()[0])
        }
    }

