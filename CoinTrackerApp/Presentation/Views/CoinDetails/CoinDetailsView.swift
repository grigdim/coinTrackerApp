//
//  CoinDetailsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Combine
import SwiftUI

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
    @State private var showingCreateAlert = false
    @EnvironmentObject private var env: AppEnvironment

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
            // Do not rewire NotificationManager here; it’s done at app root.
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
                    let isSaved = watchlistsViewModel.watchlists.contains {
                        list in
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
        VStack(spacing: 16) {
            PriceHeaderView(coin: coinDetails)

            StatsGridView(coin: coinDetails)

            // Use the shared AlertStore from the app environment
            PriceChartView(coinId: coinDetails.id, alertStore: env.alertStore)

            AlertsSectionView(coinId: coinDetails.id)

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

    private struct AlertsSectionView: View {
        let coinId: String
        @EnvironmentObject var alertStore: AlertStore   // Changed to observe AlertStore directly
        @State private var showingCreateAlert = false

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                let alerts = alertStore.alerts(coinId: coinId)
                let unread = alertStore.unreadHistoryCount(coinId: coinId)

                HStack {
                    Text("Alerts")
                        .font(.headline)

                    Spacer()

                    if unread > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "bell.badge")
                            Text("\(unread)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    }
                }

                if alerts.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "bell")
                            .foregroundColor(.secondary)
                        Text("No alerts yet. Tap Seed to add one.")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                } else {
                    VStack(spacing: 8) {
                        ForEach(alerts) { alert in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(alertTitle(alert))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(alertSubtitle(alert))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Toggle(
                                    "",
                                    isOn: Binding(
                                        get: { alert.isEnabled },
                                        set: { newValue in
                                            alertStore.toggleEnabled(
                                                alertId: alert.id,
                                                isEnabled: newValue
                                            )
                                        }
                                    )
                                )
                                .labelsHidden()

                                Button(role: .destructive) {
                                    alertStore.delete(alert)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 12,
                                    style: .continuous
                                )
                                .fill(Color.gray.opacity(0.08))
                            )
                        }
                    }
                }

                HStack {
                    Button {
                        showingCreateAlert = true
                    } label: {
                        Label(Constants.ADD_ALERT, systemImage: "bolt.fill")
                    }
                }
                .font(.subheadline)
                .padding(.top, 4)
            }
            .onAppear {
                let alerts = alertStore.alerts(coinId: coinId)
                print(
                    "AlertsSectionView alertStore:",
                    ObjectIdentifier(alertStore).hashValue,
                    "active:", alertStore.active.count,
                    "filtered:", alerts.count,
                    "coinId:", coinId
                )
            }.sheet(isPresented: $showingCreateAlert){
                NewAlertModal(coinId: coinId, alertStore: alertStore)
            }
        }

        private func alertTitle(_ alert: CoinPriceAlert) -> String {
            switch alert.type {
            case .above:
                return "Price above \(formatCurrency(alert.targetPrice))"
            case .below:
                return "Price below \(formatCurrency(alert.targetPrice))"
            case .percentage:
                return "Change ±\(formatPercent(alert.targetPrice))"
            }
        }

        private func alertSubtitle(_ alert: CoinPriceAlert) -> String {
            var parts: [String] = []
            parts.append(
                "Created "
                    + alert.createdAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
            )
            if alert.isEnabled == false {
                parts.append("Disabled")
            }
            return parts.joined(separator: " • ")
        }

        private func formatCurrency(_ value: Double) -> String {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.currencyCode = "USD"
            nf.maximumFractionDigits = 2
            nf.minimumFractionDigits = 0
            return nf.string(from: NSNumber(value: value)) ?? "$\(value)"
        }

        private func formatPercent(_ value: Double) -> String {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 2
            nf.minimumFractionDigits = 0
            return nf.string(from: NSNumber(value: value)) ?? "\(value)"
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
    .environmentObject(AppEnvironment())
    .environmentObject(AppEnvironment().alertStore) // Ensure preview also injects AlertStore
}
