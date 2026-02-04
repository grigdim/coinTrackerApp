import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var isListMode: Bool = true
    @State private var isShowingFilters: Bool = false
    @State private var filters: SearchFilters = .default
    @StateObject private var viewModel: SearchViewModel
    @State private var selectedCategoryId: String = "layer-1"
    @State private var isSwitchingCategory: Bool = false

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .task(id: selectedCategoryId) {
                isSwitchingCategory = true
                defer { isSwitchingCategory = false }
                await viewModel.loadMarketRows(for: selectedCategoryId)
            }
            .searchable(text: $searchText, prompt: "Search markets")
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut) { isListMode.toggle() }
                    } label: {
                        Image(
                            systemName: isListMode
                                ? "square.grid.2x2" : "list.bullet"
                        )
                    }
                    .accessibilityLabel(isListMode ? "Show grid" : "Show list")
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut) { isShowingFilters.toggle() }
                    } label: {
                        Image(
                            systemName: "line.3.horizontal.decrease"
                        )
                    }
                }
            }
            .navigationDestination(for: CoinDetailsRoute.self) { route in
                CoinDetailsView(route: route)
            }
            .sheet(isPresented: $isShowingFilters) {
                SearchFiltersSheet(
                    current: filters,
                    currentCategoryId: selectedCategoryId,
                    categories: viewModel.categories,
                    onApply: { newFilters, newCategoryId in
                        filters = newFilters
                        selectedCategoryId = newCategoryId
                    },
                    onReset: {
                        filters = .default
                        selectedCategoryId = "layer-1"
                    }
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack {
                Spacer()
                ProgressView("Loading…")
                Spacer()
            }
            .frame(maxWidth: .infinity)

        case .failed(let error):
            LoadingErrorView(error: error, onRetry: {})

        case .loaded(let marketRows):
            let filtered = marketRows.filter {
                searchText.isEmpty
                    || $0.name.localizedCaseInsensitiveContains(searchText)
            }
            .filter { row in
                filters.matches(row)
            }

            let shouldPaginate = searchText.isEmpty && !isSwitchingCategory
            let thresholdIndex = max(0, filtered.count - 5)

            if filtered.isEmpty {
                NoSearchResultsView()
            } else if isListMode {
                List {
                    // Render the list directly to avoid double-filtering + index mismatch
                    ForEach(Array(filtered.enumerated()), id: \.element.id) {
                        index,
                        row in
                        NavigationLink(
                            value: CoinDetailsRoute(
                                id: row.id,
                                name: row.name,
                                iconURL: row.iconURL
                            )
                        ) {
                            MarketRowItemView(row: row) {
                                guard shouldPaginate else { return }
                                guard index >= thresholdIndex else { return }
                                guard !viewModel.isLoadingNextPage else {
                                    return
                                }
                                Task {
                                    await viewModel.loadNextPage(
                                        for: selectedCategoryId
                                    )
                                }
                            }
                        }
                    }

                    if shouldPaginate, viewModel.isLoadingNextPage {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .refreshable {
                    await viewModel.refreshMarketRows(for: selectedCategoryId)
                }
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 150), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(Array(filtered.enumerated()), id: \.element.id)
                        { index, row in
                            NavigationLink(
                                value: CoinDetailsRoute(
                                    id: row.id,
                                    name: row.name,
                                    iconURL: row.iconURL
                                )
                            ) {
                                MarketGridItemView(coin: row) {
                                    guard shouldPaginate else { return }
                                    guard index >= thresholdIndex else {
                                        return
                                    }
                                    guard !viewModel.isLoadingNextPage else {
                                        return
                                    }
                                    Task {
                                        await viewModel.loadNextPage(
                                            for: selectedCategoryId
                                        )
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }
                .refreshable {
                    await viewModel.refreshMarketRows(for: selectedCategoryId)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(
            viewModel: SearchViewModel(
                marketsStore: MarketsStore(
                    getMarketRows: GetMarketRowsUseCaseImpl(
                        repository: MarketRowRepositoryImpl(
                            apiClient: APIClient()
                        )
                    )
                ),
                categoriesStore: CategoriesStore(
                    getCategories: GetCategoriesUseCaseImpl(
                        repository: CategoriesRepositoryImpl(
                            apiClient: APIClient()
                        )
                    )
                )
            )
        )
    }
}
