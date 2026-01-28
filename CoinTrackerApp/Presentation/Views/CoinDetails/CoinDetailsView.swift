//
//  CoinDetailsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI
import Combine

// MARK: - Route Model
struct CoinDetailsRoute: Hashable {
    let id: String
    let name: String
    let iconURL: URL?
}

// MARK: - Main View
struct CoinDetailsView: View {
    // 1. Existing ViewModel for API Data
    @StateObject private var viewModel: CoinDetailsViewModel
    
    // 2. ViewModel for User Data (Watchlists/Persistence)
    @StateObject private var watchlistsViewModel = WatchlistsViewModel()
    
    let route: CoinDetailsRoute

    @State private var selectedChartRange: ChartRange = .day
    
    // 3. State to control the "Add to Watchlist" sheet
    @State private var showAddSheet = false

    // Dependency Injection
    init(route: CoinDetailsRoute) {
        let apiClient = APIClient()
        let repository = CoinRepositoryImpl(apiClient: apiClient)
        let useCase = GetCoinDetailsUseCaseImpl(repository: repository)
        _viewModel = StateObject(
            wrappedValue: CoinDetailsViewModel(getCoinDetails: useCase)
        )
        self.route = route
    }

    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .idle, .loading:
                HStack {
                    Spacer()
                    ProgressView("Loading…")
                    Spacer()
                }
                .padding(.vertical, 50)
                
            case .failed(let error):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)

                    Text("Couldn’t load markets").font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        Task {
                            await viewModel.refreshCoinDetails(for: route.id)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowSeparator(.hidden)
                
            case .loaded(let viewData):
                // 4. Content View
                contentView(for: viewData)
                    // 5. Present YOUR existing AddToWatchlistView here
                    .sheet(isPresented: $showAddSheet) {
                        AddToWatchlistView(
                            viewModel: watchlistsViewModel,
                            coin: viewData
                        )
                        .presentationDetents([.medium])
                    }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .task(id: route.id) {
            // Load API Data
            await viewModel.loadCoinDetails(for: route.id)
            // 6. Load User Data (so we know if the heart should be filled)
            watchlistsViewModel.loadData()
        }
        .refreshable {
            await viewModel.refreshCoinDetails(for: route.id)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    AsyncImage(url: route.iconURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .empty:
                            ProgressView()
                        default:
                            Image(systemName: "bitcoinsign.circle")
                        }
                    }
                    .frame(width: 20, height: 20)

                    Text(route.name)
                        .font(.headline)
                }
            }

            // 7. Updated Heart Button Logic
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    // Check if coin exists in ANY watchlist to determine icon state
                    let isSaved = watchlistsViewModel.watchlists.contains { list in
                        list.coins.contains { $0.id == route.id }
                    }
                    
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(isSaved ? .red : .primary)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func contentView(for coinDetails: CoinDetails) -> some View {
        VStack (spacing: 16) {
            PriceHeaderView(coin: coinDetails)

            StatsGridView(coin: coinDetails)

            PriceChartView(coinId: coinDetails.id)

            ExpandableTextView(
                title: coinDetails.name,
                description: coinDetails.description
            )

            LinksSectionView(coin: coinDetails)
        }
    }

    // MARK: - Subviews
    private struct PriceHeaderView: View {
        let coin: CoinDetails

        var body: some View {
            VStack(spacing: 6) {
                Text(coin.price)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack(spacing: 8) {
                    Text(coin.symbol)
                        .foregroundColor(.secondary)

                    Text(coin.change24h)
                        .foregroundColor(coin.isUp ? .green : .red)
                }
                .font(.title3)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private struct StatsGridView: View {
        let coin: CoinDetails

        private let gridColumns: [GridItem] = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ]

        var body: some View {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                StatCardView(title: "Market Cap", value: coin.marketCap)
                StatCardView(title: "Volume", value: coin.volume)
                StatCardView(title: "ATH", value: coin.ath)
                StatCardView(title: "ATL", value: coin.atl)
            }
        }
    }

    private struct LinksSectionView: View {
        let coin: CoinDetails

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Links")
                    .font(.headline)

                LinkRowView(title: "Website:", url: coin.websiteURL)
                LinkRowView(title: "Explorer:", url: coin.explorerURL)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CoinDetailsView(
            route: .init(
                id: "bitcoin",
                name: "Bitcoin",
                iconURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png")
            )
        )
    }
}
