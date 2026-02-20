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
                EmptyStateView(
                    title: "No coins yet",
                    message: "Tap + to add your first coin to this watchlist.",
                    systemImage: "star.slash"
                )
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
                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: 16,
                                bottom: 0,
                                trailing: 16
                            )
                        )
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

        .sheet(isPresented: $isShowingAddSheet) {
            WatchlistCoinPickerSheet(watchlist: $watchlist)
                .environmentObject(viewModel)
        }

        // MARK: - Sheet 1: Add to Portfolio (Triggered by Swipe)
        .sheet(item: $selectedCoinForPortfolio) { coin in
            AddAssetFromWatchlistView(coin: coin)
                .environmentObject(viewModel)
            .presentationDetents([.medium])
        }

    }

    private func deleteCoin(_ coin: CoinDetails) {
        if let index = watchlist.coins.firstIndex(where: { $0.id == coin.id }) {
            watchlist.coins.remove(at: index)
        }
    }
}

private struct WatchlistCoinPickerSheet: View {
    @Binding var watchlist: Watchlist
    @EnvironmentObject private var portfolioViewModel: PortfolioViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""

    private var filteredRows: [MarketRow] {
        let rows = portfolioViewModel.availableCoins
        guard !searchText.isEmpty else { return rows }
        return rows.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch portfolioViewModel.searchState {
                case .idle, .loading:
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading coins…")
                            .foregroundStyle(.secondary)
                    }
                case .failed(let error):
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Text("Couldn’t load coins")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                case .loaded:
                    if filteredRows.isEmpty {
                        NoSearchResultsView()
                    } else {
                        List(filteredRows) { row in
                            Button {
                                addCoin(row)
                            } label: {
                                HStack(spacing: 10) {
                                    AsyncImage(url: row.iconURL) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Circle().fill(Color.gray.opacity(0.2))
                                    }
                                    .frame(width: 28, height: 28)
                                    .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(row.name)
                                            .foregroundStyle(.primary)
                                        Text(row.symbol.uppercased())
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()

                                    if watchlist.coins.contains(where: { $0.id == row.id })
                                    {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Image(systemName: "plus")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search markets")
            .navigationTitle("Add Coin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task {
            await portfolioViewModel.loadAvailableCoins()
        }
    }

    private func addCoin(_ row: MarketRow) {
        guard !watchlist.coins.contains(where: { $0.id == row.id }) else {
            dismiss()
            return
        }

        watchlist.coins.append(
            CoinDetails(
                id: row.id,
                name: row.name,
                symbol: row.symbol,
                iconURL: row.iconURL,
                price: row.price,
                change24h: row.change24h,
                isUp: row.isUp,
                marketCap: row.marketCap,
                volume: row.volume,
                circulatingSupply: row.circulatingSupply,
                ath: row.ath,
                atl: row.atl,
                sparkline: row.sparkline,
                description: nil,
                websiteURL: nil,
                explorerURL: nil,
                subredditURL: nil
            )
        )
        dismiss()
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
