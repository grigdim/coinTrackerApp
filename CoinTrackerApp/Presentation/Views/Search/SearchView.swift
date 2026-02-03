import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var isListMode: Bool = true
    @State private var isShowingFilters: Bool = false
    @State private var filters: SearchFilters = .default
    @StateObject private var viewModel: SearchViewModel
    @State private var selectedCategoryId: String = "layer-1"

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
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
                    onApply: { newFilters, newCategory in
                        filters = newFilters
                        selectedCategoryId = newCategory
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

            if filtered.isEmpty {
                NoSearchResultsView()
            } else if isListMode {
                List {
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
                            MarketRowItemView(row: row, onRowAppear: {})
                        }
                    }
                }
                .listStyle(.plain)

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
                                MarketGridItemView(coin: row, index: index)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(
            viewModel: SearchViewModel(
                store: MarketsStore(
                    getMarketRows: GetMarketRowsUseCaseImpl(
                        repository: MarketRowRepositoryImpl(
                            apiClient: APIClient()
                        )
                    )
                )
            )
        )
    }
}
