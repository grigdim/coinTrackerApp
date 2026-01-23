import SwiftUI

enum MarketCategory: String, CaseIterable, Identifiable {
    case top100 = "Top 100"
    case trending = "Trending"
    case gainers = "Gainers"
    case losers = "Losers"

    var id: String { rawValue }
}

private struct MarketOverviewNoSearchResultsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("No results")
                .font(.headline)

            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct MarketOverviewView: View {
    @StateObject private var viewModel: MarketOverviewViewModel
    @State private var selectedCategory: MarketCategory = .top100
    @State private var searchText: String = ""
    @State private var isSwitchingCategory: Bool = false
    @State private var latestOffsets: [String: CGFloat] = [:]
    @State private var switchTask: Task<Void, Never>?
    @State private var displayedCategory: MarketCategory = .top100

    init() {
        let apiClient = APIClient()
        let repo = MarketRowRepositoryImpl(apiClient: apiClient)
        let useCase = GetMarketRowsUseCaseImpl(repository: repo)
        _viewModel = StateObject(
            wrappedValue: MarketOverviewViewModel(getMarketRows: useCase)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Category", selection: $selectedCategory) {
                ForEach(MarketCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // We keep the search host (List) present and change content within it.
            // This reduces search bar jumping/disappearing.
            contentList
        }
        .task {
            displayedCategory = selectedCategory
            await viewModel.loadMarketRows(for: selectedCategory)
        }
        .navigationDestination(for: CoinDetailsRoute.self) { route in
            CoinDetailsView(route: route)
        }
    }

    private var contentList: some View {
        // Resolve coins for the list without removing the list from the hierarchy.
        let coins: [MarketRow] = {
            if case .loaded(let c) = viewModel.state { return c }
            return []
        }()

        let filtered = coins.filter {
            searchText.isEmpty
                || $0.name.localizedCaseInsensitiveContains(searchText)
        }

        let shouldPaginate = selectedCategory == .top100 && searchText.isEmpty
        let thresholdIndex = max(0, filtered.count - 5)

        return ScrollViewReader { proxy in
            List {
                listRows(
                    shouldPaginate: shouldPaginate,
                    thresholdIndex: thresholdIndex
                )
            }
            .listStyle(.plain)
            .coordinateSpace(name: "marketScrolled")
            .searchable(text: $searchText, prompt: "Search coins")
            .refreshable {
                await viewModel.refreshMarketRows(for: selectedCategory)
            }
            .overlay {
                if case .loaded = viewModel.state, filtered.isEmpty {
                    MarketOverviewNoSearchResultsView()
                }
            }
            .onPreferenceChange(RowOffsetKey.self) { offsets in
                latestOffsets = offsets
                guard !isSwitchingCategory else { return }

                let visible = offsets.filter { $0.value >= 0 }
                if let topMost = visible.min(by: { $0.value < $1.value })?.key {

                    viewModel.saveScrolledAnchor(
                        for: displayedCategory,
                        id: topMost
                    )
                }
            }
            .onChange(of: selectedCategory) { newValue in
                // Cancel any in-flight switch task so only the latest selection wins
                switchTask?.cancel()

                switchTask = Task {
                    // 1) Save anchor for the category currently displayed BEFORE switching
                    let visible = latestOffsets.filter { $0.value >= 0 }
                    if let topMost = visible.min(by: { $0.value < $1.value })?
                        .key
                    {
                        viewModel.saveScrolledAnchor(
                            for: displayedCategory,
                            id: topMost
                        )
                    }

                    isSwitchingCategory = true
                    defer {
                        // allow saving again after a brief settle
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            isSwitchingCategory = false
                        }
                    }

                    // 2) Load data for the new category
                    await viewModel.loadMarketRows(for: newValue)
                    guard !Task.isCancelled else { return }
                    guard selectedCategory == newValue else { return }

                    // 3) Update displayedCategory only once data is now the source of truth
                    displayedCategory = newValue

                    // 4) Yield so the list lays out
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    guard !Task.isCancelled else { return }

                    // 5) Restore anchor or fallback to first row (Fix A)
                    if let anchor = viewModel.scrollToAnchor(for: newValue) {
                        proxy.scrollTo(anchor, anchor: .top)
                    } else if case .loaded(let coins) = viewModel.state,
                        let firstId = coins.first?.id
                    {
                        proxy.scrollTo(firstId, anchor: .top)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func listRows(shouldPaginate: Bool, thresholdIndex: Int)
        -> some View
    {
        switch viewModel.state {
        case .idle, .loading:
            HStack {
                Spacer()
                ProgressView("Loading…")
                Spacer()
            }
            .listRowSeparator(.hidden)

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
                        await viewModel.refreshMarketRows(for: selectedCategory)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .listRowSeparator(.hidden)

        case .loaded(let coins):
            let filtered = coins.filter {
                searchText.isEmpty
                    || $0.name.localizedCaseInsensitiveContains(searchText)
            }

            ForEach(Array(filtered.enumerated()), id: \.element.id) {
                index,
                coin in
                marketRow(
                    coin: coin,
                    index: index,
                    thresholdIndex: thresholdIndex,
                    shouldPaginate: shouldPaginate
                )
            }

            if shouldPaginate && viewModel.isLoadingNextPage {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private func marketRow(
        coin: MarketRow,
        index: Int,
        thresholdIndex: Int,
        shouldPaginate: Bool
    ) -> some View {
        NavigationLink(
            value: CoinDetailsRoute(
                id: coin.id,
                name: coin.name,
                iconURL: coin.iconURL
            )
        ) {
            CoinRowView(coin: coin)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: RowOffsetKey.self,
                            value: [
                                coin.id: geo.frame(in: .named("marketScrolled"))
                                    .minY
                            ]
                        )
                    }
                )
        }
        .id(coin.id)
    }
}

#Preview {
    NavigationStack {
        MarketOverviewView()
            .navigationTitle("Markets")
            .navigationBarTitleDisplayMode(.inline)
    }
}
