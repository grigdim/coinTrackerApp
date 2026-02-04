import Combine
import Foundation

final class SearchViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[MarketRow]> = .idle
    @Published private(set) var isLoadingNextPage: Bool = false
    @Published private(set) var categories: [Category] = []
    @Published var searchText: String = ""

    private let marketsStore: MarketsStore
    private let categoriesStore: CategoriesStore
    private var activeCategory: String = "layer-1"

    private let perPage: Int = 20
    private let cacheTTL: TimeInterval = 60

    init(marketsStore: MarketsStore, categoriesStore: CategoriesStore) {
        self.marketsStore = marketsStore
        self.categoriesStore = categoriesStore

        categoriesStore.$categories.receive(on: DispatchQueue.main).assign(
            to: &$categories
        )
    }

    func loadMarketRows(for category: String) async {
        activeCategory = category

        let cached = marketsStore.cachedRows(for: category)
        if !cached.isEmpty {
            state = .loaded(cached)

            if let fetchedAtByCategory = marketsStore.fetchedAt(for: category),
                !isStale(fetchedAtByCategory, cacheTTL: cacheTTL)
            {
                return
            }
        }

        await refreshMarketRows(for: category)
    }

    func refreshMarketRows(for category: String) async {
        activeCategory = category
        state = .loading

        do {
            let marketRows = try await marketsStore.refresh(
                category: category,
                perPage: perPage
            )

            guard activeCategory == category else { return }

            state = .loaded(marketRows)

        } catch {
            let cached = marketsStore.cachedRows(for: category)
            if !cached.isEmpty {
                state = .loaded(cached)
            } else {
                state = .failed(error)
            }
        }
    }

    func loadNextPage(for category: String) async {
        guard activeCategory == category else { return }
        guard case .loaded(let currentRows) = state else { return }
        guard !isLoadingNextPage else { return }

        isLoadingNextPage = true
        defer {
            isLoadingNextPage = false
        }

        do {
            let newRows = try await marketsStore.loadNextPage(
                category: category,
                perPage: perPage
            )
            guard activeCategory == category else { return }
            state = .loaded(newRows)

        } catch {
            guard activeCategory == category else { return }
            state = .loaded(currentRows)
        }
    }
}
