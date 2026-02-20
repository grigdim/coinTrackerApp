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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowingFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .imageScale(.medium)
                    }
                    .accessibilityLabel("Filters")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isListMode.toggle()
                        }
                    } label: {
                        Image(
                            systemName: isListMode
                                ? "square.grid.2x2" : "list.bullet"
                        )
                        .imageScale(.medium)
                    }
                    .accessibilityLabel(isListMode ? "Show grid" : "Show list")
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
            .animation(.easeInOut(duration: 0.2), value: isListMode)
            .animation(
                .easeInOut(duration: 0.2),
                value: viewModel.stateKeyForAnimation
            )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            VStack(spacing: 12) {
                Spacer()
                ProgressView("Loading…")
                Spacer()
            }
            .frame(maxWidth: .infinity)

        case .failed(let error):
            LoadingErrorView(error: error, onRetry: {})

        case .loaded(let marketRows):
            let filtered =
                marketRows
                .filter {
                    searchText.isEmpty
                        || $0.name.localizedCaseInsensitiveContains(searchText)
                }
                .filter { filters.matches($0) }

            let shouldPaginate = searchText.isEmpty && !isSwitchingCategory
            let thresholdIndex = max(0, filtered.count - 5)

            if filtered.isEmpty {
                VStack {
                    Spacer(minLength: 40)
                    NoSearchResultsView()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else if isListMode {
                listView(
                    filtered: filtered,
                    shouldPaginate: shouldPaginate,
                    thresholdIndex: thresholdIndex
                )
            } else {
                gridView(
                    filtered: filtered,
                    shouldPaginate: shouldPaginate,
                    thresholdIndex: thresholdIndex
                )
            }
        }
    }

    private func listView(
        filtered: [MarketRow],
        shouldPaginate: Bool,
        thresholdIndex: Int
    ) -> some View {
        List {
            ForEach(filtered.indices, id: \.self) { index in
                let row = filtered[index]

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
                        guard !viewModel.isLoadingNextPage else { return }

                        Task {
                            await viewModel.loadNextPage(
                                for: selectedCategoryId
                            )
                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowInsets(
                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                )
            }

            if shouldPaginate && viewModel.isLoadingNextPage {
                HStack(spacing: 10) {
                    Spacer()
                    ProgressView()
                    Text("Loading more…")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 12)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search markets")
        .submitLabel(.search)
        .refreshable {
            await viewModel.refreshMarketRows(for: selectedCategoryId)
        }
        .scrollIndicators(.hidden)
    }

    private func gridView(
        filtered: [MarketRow],
        shouldPaginate: Bool,
        thresholdIndex: Int
    ) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150), spacing: 12)],
                spacing: 12
            ) {
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
                        MarketGridItemView(coin: row) {
                            guard shouldPaginate else { return }
                            guard index >= thresholdIndex else { return }
                            guard !viewModel.isLoadingNextPage else { return }

                            Task {
                                await viewModel.loadNextPage(
                                    for: selectedCategoryId
                                )
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if shouldPaginate && viewModel.isLoadingNextPage {
                    HStack(spacing: 10) {
                        Spacer()
                        ProgressView()
                        Text("Loading more…")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(12)
        }
        .searchable(text: $searchText, prompt: "Search markets")
        .refreshable {
            await viewModel.refreshMarketRows(for: selectedCategoryId)
        }
        .scrollIndicators(.hidden)
    }
}

extension SearchViewModel {
    fileprivate var stateKeyForAnimation: String {
        switch state {
        case .idle: return "idle"
        case .loading: return "loading"
        case .failed: return "failed"
        case .loaded(let rows): return "loaded-\(rows.count)"
        }
    }
}

#Preview {
    let marketsStore = MarketsStore(
        getMarketRows: GetMarketRowsUseCaseImpl(
            repository: MarketRowRepositoryImpl(
                apiClient: APIClient()
            )
        )
    )

    let categoriesStore = CategoriesStore(
        getCategories: GetCategoriesUseCaseImpl(
            repository: CategoriesRepositoryImpl(
                apiClient: APIClient()
            )
        )
    )

    NavigationStack {
        SearchView(
            viewModel: SearchViewModel(
                marketsStore: marketsStore,
                categoriesStore: categoriesStore
            )
        )
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }
    .task {
        await categoriesStore.loadIfNeeded()
    }
}
