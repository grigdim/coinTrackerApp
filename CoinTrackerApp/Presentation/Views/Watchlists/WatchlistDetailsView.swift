//
//  WatchlistDetailView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct WatchlistDetailView: View {
    @Binding var watchlist: Watchlist
    @EnvironmentObject var viewModel: PortfolioViewModel
    
    @State private var selectedCoinForPortfolio: CoinDetails?
    @State private var isShowingAddSheet = false
    
    var body: some View {
        Group {
            if watchlist.coins.isEmpty {
                EmptyStateView()
            } else {
                List {
                    ForEach(watchlist.coins) { coinDetail in
                        NavigationLink {
                            CoinDetailsView(
                                route: CoinDetailsRoute(
                                    id: coinDetail.id,
                                    name: coinDetail.name,
                                    iconURL: coinDetail.iconURL
                                )
                            )
                        } label: {
                            CoinRowView(coin: coinDetail.toMarketRow)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .leading) {
                            Button {
                                selectedCoinForPortfolio = coinDetail
                            } label: {
                                Label("Portfolio", systemImage: "case.fill")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteCoin(coinDetail)
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
        
        // MARK: - Toolbar (Add Coin to Watchlist)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        
        // MARK: - Sheet 1: Add to Portfolio (Triggered by Swipe)
        .sheet(item: $selectedCoinForPortfolio) { coin in
            AddAssetFromWatchlistView(
                viewModel: _viewModel,
                coin: coin
            )
            .presentationDetents([.medium])
        }
    
    }
    
    private func deleteCoin(_ coin: CoinDetails) {
        if let index = watchlist.coins.firstIndex(where: { $0.id == coin.id }) {
            watchlist.coins.remove(at: index)
        }
    }
}

// MARK: - Preview Helper
#Preview {
    NavigationStack {
        WatchlistDetailView(
            watchlist: .constant(Watchlist.mocks()[0])
        )
        .environmentObject(
            PortfolioViewModel(
                repository: MarketRowRepositoryImpl(apiClient: APIClient())
            )
        )
    }
}
