//
//  WatchlistDetailView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct WatchlistDetailView: View {
    @Binding var watchlist: Watchlist
    @EnvironmentObject private var portfolioViewModel: PortfolioViewModel

    @State private var selectedCoinForPortfolio: MarketRow?
    @State private var isShowingAddSheet = false

    @State private var rowsByID: [String: MarketRow] = [:]
    @State private var isLoadingRows = false
    @State private var loadErrorMessage: String?

    var body: some View {
        Group {
            if watchlist.coinIDs.isEmpty {
                EmptyStateView(
                    title: "No coins yet",
                    message: "Tap + to add your first coin to this watchlist.",
                    systemImage: "star.slash"
                )
            } else {
                List {
                    if let loadErrorMessage, resolvedRows.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Couldn’t refresh some watchlist rows")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(loadErrorMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button("Retry") {
                                Task {
                                    await refreshRows()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 6)
                        .listRowSeparator(.hidden)
                    }

                    ForEach(watchlist.coinIDs, id: \.self) { coinID in
                        if let row = rowsByID[coinID] {
                            rowView(row)
                        } else {
                            unresolvedRow(coinID: coinID)
                        }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if isLoadingRows && resolvedRows.isEmpty {
                        ProgressView("Loading coins…")
                    }
                }
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
                .environmentObject(portfolioViewModel)
        }

        // MARK: - Sheet 1: Add to Portfolio (Triggered by Swipe)
        .sheet(item: $selectedCoinForPortfolio) { row in
            AddAssetFromWatchlistView(coin: row)
                .environmentObject(portfolioViewModel)
                .presentationDetents([.medium])
        }
        .task(id: watchlist.coinIDs) {
            await refreshRows()
        }

    }

    private var resolvedRows: [MarketRow] {
        watchlist.coinIDs.compactMap { rowsByID[$0] }
    }

    private func rowView(_ row: MarketRow) -> some View {
        NavigationLink {
            CoinDetailsView(
                route: CoinDetailsRoute(
                    id: row.id,
                    name: row.name,
                    symbol: row.symbol,
                    iconURL: row.iconURL
                )
            )
        } label: {
            CoinRowView(coin: row)
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
                selectedCoinForPortfolio = row
            } label: {
                Label("Portfolio", systemImage: "case.fill")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteCoin(withID: row.id)
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }

    private func unresolvedRow(coinID: String) -> some View {
        NavigationLink {
            CoinDetailsView(
                route: CoinDetailsRoute(
                    id: coinID,
                    name: coinID,
                    symbol: coinID.uppercased(),
                    iconURL: nil
                )
            )
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.secondary)
                    .imageScale(.large)

                VStack(alignment: .leading, spacing: 2) {
                    Text(coinID)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Live quote unavailable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 8)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteCoin(withID: coinID)
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                selectedCoinForPortfolio = placeholderRow(for: coinID)
            } label: {
                Label("Portfolio", systemImage: "case.fill")
            }
            .tint(.blue)
        }
    }

    private func deleteCoin(withID coinID: String) {
        if let index = watchlist.coinIDs.firstIndex(of: coinID) {
            watchlist.coinIDs.remove(at: index)
            rowsByID[coinID] = nil
        }
    }

    private func refreshRows() async {
        let validIDs = Set(watchlist.coinIDs)
        rowsByID = rowsByID.filter { validIDs.contains($0.key) }

        guard !watchlist.coinIDs.isEmpty else {
            loadErrorMessage = nil
            isLoadingRows = false
            return
        }

        // Fast local seed from already-cached rows.
        let cachedRows = portfolioViewModel.availableCoins.filter {
            validIDs.contains($0.id)
        }
        mergeRows(cachedRows)

        isLoadingRows = true
        defer { isLoadingRows = false }
        loadErrorMessage = nil

        do {
            let liveRows = try await portfolioViewModel.fetchRowsForCoinIDs(
                watchlist.coinIDs
            )
            mergeRows(liveRows)
        } catch {
            loadErrorMessage = error.localizedDescription
        }
    }

    private func mergeRows(_ rows: [MarketRow]) {
        for row in rows {
            rowsByID[row.id] = row
        }
    }

    private func placeholderRow(for coinID: String) -> MarketRow {
        MarketRow(
            id: coinID,
            name: coinID,
            symbol: coinID.uppercased(),
            iconURL: nil,
            price: "—",
            priceRaw: 0,
            marketCap: "—",
            marketCapRaw: 0,
            volume: "—",
            volumeRaw: 0,
            circulatingSupply: "—",
            ath: "—",
            atl: "—",
            change24h: "—",
            change24hRaw: 0,
            isUp: true,
            sparkline: [],
            currentPriceRaw: 0
        )
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

                                    if watchlist.coinIDs.contains(row.id) {
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
        guard !watchlist.coinIDs.contains(row.id) else {
            dismiss()
            return
        }

        watchlist.coinIDs.append(row.id)
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
