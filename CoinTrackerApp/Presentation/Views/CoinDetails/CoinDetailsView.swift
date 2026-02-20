//
//  CoinDetailsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Combine
import SwiftUI

// MARK: - Route Model
struct CoinDetailsRoute: Hashable, Identifiable {
    let id: String
    let name: String
    let iconURL: URL?
}

// MARK: - Main View
struct CoinDetailsView: View {
    @StateObject private var viewModel: CoinDetailsViewModel
    @EnvironmentObject private var alertStore: AlertStore

    @StateObject private var watchlistsViewModel = WatchlistsViewModel()

    let route: CoinDetailsRoute

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

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                loadingState

            case .failed(let error):
                errorState(error)

            case .loaded(let viewData):
                contentView(for: viewData)
            }
        }
        .task(id: route.id) {
            await viewModel.loadCoinDetails(for: route.id)
            watchlistsViewModel.loadData()
        }
        .refreshable {
            await viewModel.refreshCoinDetails(for: route.id)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
    }

    // MARK: - Content

    private func contentView(for coinDetails: CoinDetails) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                PriceHeaderView(coin: coinDetails)

                section {
                    StatsGridView(coin: coinDetails)
                }

                section {
                    PriceChartView(
                        coinId: coinDetails.id, 
                        alertStore: alertStore
                    )
                }

                section {
                    ExpandableTextView(
                        title: coinDetails.name,
                        description: coinDetails.description
                    )
                }

                section {
                    AlertsSectionView(coinId: coinDetails.id)
                }

                section {
                    LinksSectionView(coin: coinDetails)
                }

                Spacer(minLength: 22)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 28)  // key for tab bar overlap on iOS 16
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showAddSheet) {
            AddToWatchlistView(
                viewModel: watchlistsViewModel,
                coin: coinDetails
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading…")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
    }

    private func errorState(_ error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 38))
                .foregroundColor(.orange)

            Text("Couldn’t load coin")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task { await viewModel.refreshCoinDetails(for: route.id) }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ToolbarTitleView(
                title: route.name,
                iconURL: route.iconURL
            )
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAddSheet = true
            } label: {
                let isSaved = watchlistsViewModel.watchlists.contains { list in
                    list.coins.contains { $0.id == route.id }
                }

                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(isSaved ? .red : .primary)
            }
            .accessibilityLabel("Add to watchlist")
        }
    }

    // MARK: - Helpers (UI)

    private func section<Content: View>(@ViewBuilder _ content: () -> Content)
        -> some View
    {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Subviews

    private struct ToolbarTitleView: View {
        let title: String
        let iconURL: URL?

        var body: some View {
            HStack(spacing: 8) {
                AsyncImage(url: iconURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        Image(systemName: "bitcoinsign.circle")
                            .foregroundStyle(.secondary)
                    }
                }
                // Match nav bar symbol sizing better than 40x40 for inline mode
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)

                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }

    private struct PriceHeaderView: View {
        let coin: CoinDetails

        var body: some View {
            VStack(spacing: 8) {
                Text(coin.price)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .monospacedDigit()

                HStack(spacing: 10) {
                    Text(coin.symbol.uppercased())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Image(
                            systemName: coin.isUp
                                ? "arrow.up.right" : "arrow.down.right"
                        )
                        .font(.caption2)
                        .fontWeight(.bold)

                        Text(coin.change24h)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(coin.isUp ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                (coin.isUp ? Color.green : Color.red).opacity(
                                    0.12
                                )
                            )
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "\(coin.symbol) price \(coin.price), 24 hour change \(coin.change24h)"
            )
        }
    }

    private struct StatsGridView: View {
        let coin: CoinDetails

        private let gridColumns: [GridItem] = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Statistics")
                    .font(.headline)
                    .padding(.horizontal, 2)

                LazyVGrid(columns: gridColumns, spacing: 12) {
                    StatCardView(title: "Market Cap", value: coin.marketCap)
                        .accessibilityLabel("Market cap \(coin.marketCap)")

                    StatCardView(title: "Volume", value: coin.volume)
                        .accessibilityLabel("Volume \(coin.volume)")

                    StatCardView(title: "All-time High", value: coin.ath)
                        .accessibilityLabel("All time high \(coin.ath)")

                    StatCardView(title: "All-time Low", value: coin.atl)
                        .accessibilityLabel("All time low \(coin.atl)")
                }
            }
            .padding(.vertical, 2)
        }
    }

    private struct LinksSectionView: View {
        let coin: CoinDetails

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Links")
                    .font(.headline)
                    .padding(.horizontal, 2)

                VStack(spacing: 0) {
                    if let url = coin.websiteURL {
                        LinkRowView(title: "Website", url: url)
                    }

                    if let url = coin.explorerURL {
                        if coin.websiteURL != nil {
                            Divider().padding(.leading, 44)
                        }
                        LinkRowView(title: "Explorer", url: url)
                    }

                    if coin.websiteURL == nil && coin.explorerURL == nil {
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(.secondary)
                            Text("No links available")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(12)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            }
        }
    }
}

// Preview
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
    .environmentObject(AppEnvironment(alertStore: AlertStore()))
}
