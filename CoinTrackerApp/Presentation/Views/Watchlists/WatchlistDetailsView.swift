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
                        // Helper function to keep the main body clean
                        coinRow(for: coinDetail)
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
        // This opens your new dedicated screen
        .sheet(item: $selectedCoinForPortfolio) { coin in
            AddAssetFromWatchlistView(
                viewModel: _viewModel,
                coin: coin
            )
            .presentationDetents([.medium])
        }
        
        // MARK: - Sheet 2: Search/Add to Watchlist (Triggered by + Button)
        .sheet(isPresented: $isShowingAddSheet) {
           
        }
        
        // MARK: - Navigation Destination (Coin Details)
        .navigationDestination(for: CoinDetails.self) { coin in
            CoinDetailsView(
                route: CoinDetailsRoute(
                    id: coin.id,
                    name: coin.name,
                    iconURL: coin.iconURL
                )
            )
        }
    }
    
    // MARK: - Row Component
    
    @ViewBuilder
    private func coinRow(for coinDetail: CoinDetails) -> some View {
        CoinRowView(coin: coinDetail.toMarketRow)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
        
            // MARK: - Swipe Leading: Add to Portfolio
            .swipeActions(edge: .leading) {
                Button {
                    // Setting this state triggers Sheet 1
                    selectedCoinForPortfolio = coinDetail
                } label: {
                    Label("Portfolio", systemImage: "case.fill")
                }
                .tint(.blue)
            }
        
            // MARK: - Swipe Trailing: Delete from Watchlist
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    deleteCoin(coinDetail)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        
            // Invisible Link for Tap Navigation
            .background(
                NavigationLink("", value: coinDetail)
                    .opacity(0)
            )
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
        // Inject the environment object for the preview to work
        .environmentObject(PortfolioViewModel(
            repository: MarketRowRepositoryImpl(apiClient: APIClient())
        ))
    }
}
