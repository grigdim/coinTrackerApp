import SwiftUI

enum MarketCategory: String, CaseIterable, Identifiable {
    case top100 = "Top 100"
    case trending = "Trending"
    case gainers = "Gainers"
    case losers = "Losers"

    var id: String { rawValue }
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
                MarketsListView(
                    state: viewModel.state,
                    searchText: searchText,
                    shouldPaginate: shouldPaginate,
                    thresholdIndex: thresholdIndex,
                    onRetry: {
                        Task { await viewModel.refreshMarketRows(for: selectedCategory) }
                    }
                )
            }
            .listStyle(.plain)
            .coordinateSpace(name: "marketScrolled")
            .searchable(text: $searchText, prompt: "Search markets")
            .refreshable {
                await viewModel.refreshMarketRows(for: selectedCategory)
            }
            .overlay {
                if case .loaded = viewModel.state, filtered.isEmpty {
                    NoSearchResultsView()
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




}

#Preview {
    NavigationStack {
        MarketOverviewView()
            .navigationTitle("Markets")
            .navigationBarTitleDisplayMode(.inline)
    }
}
