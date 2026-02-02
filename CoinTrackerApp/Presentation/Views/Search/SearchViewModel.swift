import Combine
import Foundation

final class SearchViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[MarketRow]> = .idle
    @Published private(set) var isLoadingNextPage: Bool = false
    @Published private(set) var categories: [Category] = []
    @Published var searchText: String = ""

    private let store: MarketsStore
    private var activeCategory: MarketCategory = .top100

    private let perPage: Int = 100
    private let cacheTTL: TimeInterval = 60

    init(store: MarketsStore) {
        self.store = store
    }

    func loadMarketRows(for category: MarketCategory) async {
        activeCategory = category

        let cached = store.cachedRows(for: category)
        if !cached.isEmpty {
            state = .loaded(cached)

            if let fetchedAtByCategory = store.fetchedAt(for: category),
                !isStale(fetchedAtByCategory, cacheTTL: cacheTTL)
            {
                return
            }
        }

        await refreshMarketRows(for: category)
    }

    func refreshMarketRows(for category: MarketCategory) async {
        state = .loading

        do {
            let marketRows = try await store.refresh(
                category: category,
                perPage: perPage
            )

            let finalRows: [MarketRow]
            switch category {
            case .gainers:
                finalRows = marketRows.sorted {
                    $0.change24hRaw > $1.change24hRaw
                }
            case .losers:
                finalRows = marketRows.sorted {
                    $0.change24hRaw < $1.change24hRaw
                }
            default:
                finalRows = marketRows
            }

            state = .loaded(finalRows)

        } catch {
            let cached = store.cachedRows(for: category)
            if !cached.isEmpty {
                // Keep showing cached data if refresh fails
                state = .loaded(cached)
            } else {
                state = .failed(error)
            }
        }
    }

}
