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

    init(viewModel: MarketOverviewViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            categoryPicker
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

    // MARK: - UI

    private var categoryPicker: some View {
        VStack(spacing: 8) {
            Picker("Category", selection: $selectedCategory) {
                ForEach(MarketCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Color(.systemBackground))
    }

    private var contentList: some View {
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

        func onRowAppear(_ index: Int) {
            guard shouldPaginate else { return }
            guard !isSwitchingCategory else { return }
            guard index >= thresholdIndex else { return }
            guard !viewModel.isLoadingNextPage else { return }

            Task { await viewModel.loadNextPage(for: selectedCategory) }
        }

        return ScrollViewReader { proxy in
            List {
                MarketsListView(
                    state: viewModel.state,
                    searchText: searchText,
                    onRetry: {
                        Task {
                            await viewModel.refreshMarketRows(
                                for: selectedCategory
                            )
                        }
                    },
                    onRowAppear: onRowAppear
                )

                if shouldPaginate && viewModel.isLoadingNextPage {
                    HStack(spacing: 10) {
                        Spacer()
                        ProgressView()
                            .controlSize(.regular)
                        Text("Loading more…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .listRowSeparator(.hidden)
                }
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
                switchTask?.cancel()

                switchTask = Task {
                    // Save anchor for currently displayed category
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
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 100_000_000)
                            isSwitchingCategory = false
                        }
                    }

                    // Load new category
                    await viewModel.loadMarketRows(for: newValue)
                    guard !Task.isCancelled else { return }
                    guard selectedCategory == newValue else { return }

                    displayedCategory = newValue

                    // Let list lay out, then restore scroll anchor
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    guard !Task.isCancelled else { return }

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
        MarketOverviewView(
            viewModel: MarketOverviewViewModel(
                store: MarketsStore(
                    getMarketRows: GetMarketRowsUseCaseImpl(
                        repository: MarketRowRepositoryImpl(
                            apiClient: APIClient()
                        )
                    )
                )
            )
        )
        .navigationTitle("Markets")
        .navigationBarTitleDisplayMode(.inline)
    }
}
