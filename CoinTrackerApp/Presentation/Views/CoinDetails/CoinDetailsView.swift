//
//  CoinDetailsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct CoinDetailsRoute: Hashable {
    let id: String
    let name: String
    let iconURL: URL?
}

struct CoinDetailsView: View {
    @StateObject private var viewModel: CoinDetailsViewModel
    let route: CoinDetailsRoute

    @State private var selectedChartRange: ChartRange = .day
    @State private var isFavorite: Bool = false

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
                contentView(for: viewData)
            }

        }
        .padding(.horizontal)
        .padding(.top, 8)
        .task(id: route.id) {
            await viewModel.loadCoinDetails(for: route.id)
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

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut) {
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel(isFavorite ? "Unfavorite" : "Favorite")
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

#Preview {
    NavigationStack {
        CoinDetailsView(
            route: .init(
                id: "bitcoin",
                name: "Bitcoin",
                iconURL: URL(
                    string:
                        "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
                )
            )
        )
    }
}
