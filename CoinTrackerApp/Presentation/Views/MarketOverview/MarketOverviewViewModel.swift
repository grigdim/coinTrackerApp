import Combine
import Foundation

@MainActor
final class MarketOverviewViewModel: ObservableObject {

    // MARK: - Stored data
    private var cachedCoins: [MarketCategory: [CoinDetails]] = [:]

    /// Last successfully loaded page per category (Top100 uses page 1,2,3...)
    private var loadedPageByCategory: [MarketCategory: Int] = [:]

    /// Tracks which "next page" is currently being fetched, to prevent double loads.
    /// Example: for Top100, while page 2 is loading, this stores 2.
    private var inFlightPageByCategory: [MarketCategory: Int] = [:]

    /// Which category the view model considers "current" (prevents stale tasks from overwriting state)
    private var activeCategory: MarketCategory = .top100

    private(set) var scrollAnchorByCategory: [MarketCategory: String] = [:]

    // MARK: - Published state
    @Published private(set) var isLoadingNextPage: Bool = false
    @Published private(set) var state: ViewState<[CoinDetails]> = .idle

    // MARK: - Public API

    func load(for category: MarketCategory) async {
        activeCategory = category

        if let cached = cachedCoins[category], !cached.isEmpty {
            state = .loaded(cached)
            // Ensure we have a sensible loaded page for cached data
            if loadedPageByCategory[category] == nil {
                loadedPageByCategory[category] = 1
            }
            return
        }

        await refresh(for: category)
    }

    func refresh(for category: MarketCategory) async {
        activeCategory = category
        state = .loading

        // Reset paging for this category
        loadedPageByCategory[category] = 1
        inFlightPageByCategory[category] = nil

        do {
            let coins = try await fetchCoins(for: category)   // page 1 data for now
            cachedCoins[category] = coins
            state = .loaded(coins)
        } catch {
            if let cached = cachedCoins[category], !cached.isEmpty {
                state = .loaded(cached)
            } else {
                state = .failed(error)
            }
        }
    }

    func loadNextPage(for category: MarketCategory) async {
        // Only Top100 paginates
        guard category == .top100 else { return }

        // Don't let old category tasks overwrite the current UI
        guard activeCategory == category else { return }

        // Only paginate if we're currently showing loaded data
        guard case .loaded = state else { return }

        // Global guard (fine since only top100 paginates in this screen)
        guard !isLoadingNextPage else { return }

        let currentLoadedPage = loadedPageByCategory[category] ?? 1
        let nextPage = currentLoadedPage + 1

        // Dedupe: if that exact nextPage is already in flight, bail
        if inFlightPageByCategory[category] == nextPage {
            return
        }

        // Mark in-flight BEFORE awaiting
        inFlightPageByCategory[category] = nextPage
        isLoadingNextPage = true
        defer {
            isLoadingNextPage = false
            // Clear in-flight marker (only if it's still the same page)
            if inFlightPageByCategory[category] == nextPage {
                inFlightPageByCategory[category] = nil
            }
        }

        // Simulate network latency
        try? await Task.sleep(nanoseconds: 500_000_000)

        // User may have switched categories while awaiting
        guard activeCategory == category else { return }

        // Re-read current coins AFTER await to avoid appending to stale snapshot
        guard case .loaded(let currentCoinsNow) = state else { return }

        let startIndex = (nextPage - 1) * 20 + 1
        let newCoins: [CoinDetails] = (startIndex..<(startIndex + 20)).map { i in
            CoinDetails(
                id: "TOP\(i)",
                name: "Top Coin \(i)",
                symbol: "TOP\(i)",
                iconURL: nil,
                price: "\(100 + i)",
                marketCap: "\(1_000_000 + i * 10_000)",
                volume: "\(50_000 + i * 1_000)",
                circulatingSupply: "\(1_000_000 + i * 5_000)",
                ath: "\(200 + i)",
                atl: "\(10 + i)",
                change24h: "+\(10 + i)",
                isUp: true,
                sparkline: [10.0, 14.5, 12.8, 18.2, 16.9, 22.4, 20.7, 26.0],
                description: "asdf",
                externalLink: URL(string: "https://www.google.com")
            )
        }

        let merged = currentCoinsNow + newCoins
        cachedCoins[category] = merged
        state = .loaded(merged)

        // Only now that it succeeded, advance the loaded page
        loadedPageByCategory[category] = nextPage
    }

    // MARK: - Scroll anchors

    func saveScrolledAnchor(for category: MarketCategory, id: String) {
        scrollAnchorByCategory[category] = id
    }

    func scrollToAnchor(for category: MarketCategory) -> String? {
        scrollAnchorByCategory[category]
    }

    // MARK: - Mock fetch (replace with real networking later)

    private func fetchCoins(for category: MarketCategory) async throws -> [CoinDetails] {
        switch category {
        case .top100:
            return (1...20).map {
                CoinDetails(
                    id: "TOP\($0)",
                    name: "Top Coin \($0)",
                    symbol: "TOP\($0)",
                    iconURL: nil,
                    price: "\(100 + $0)",
                    marketCap: "\(1_000_000 + $0 * 10_000)",
                    volume: "\(50_000 + $0 * 1_000)",
                    circulatingSupply: "\(1_000_000 + $0 * 5_000)",
                    ath: "\(200 + $0)",
                    atl: "\(10 + $0)",
                    change24h: "+\(10 + $0)",
                    isUp: true,
                    sparkline: [10.0, 14.5, 12.8, 18.2, 16.9, 22.4, 20.7, 26.0],
                    description: "asdf",
                    externalLink: URL(string: "https://www.google.com")
                )
            }
        case .trending:
            return (1...20).map {
                CoinDetails(
                    id: "TREND\($0)",
                    name: "Trending Coin \($0)",
                    symbol: "TREND\($0)",
                    iconURL: nil,
                    price: "\(100 + $0)",
                    marketCap: "\(1_000_000 + $0 * 10_000)",
                    volume: "\(50_000 + $0 * 1_000)",
                    circulatingSupply: "\(1_000_000 + $0 * 5_000)",
                    ath: "\(200 + $0)",
                    atl: "\(10 + $0)",
                    change24h: "+\(10 + $0)",
                    isUp: true,
                    sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9],
                    description: "asdf",
                    externalLink: URL(string: "https://www.google.com")
                )
            }
        case .gainers:
            return (1...20).map {
                CoinDetails(
                    id: "GAIN\($0)",
                    name: "Gainer Coin \($0)",
                    symbol: "GAIN\($0)",
                    iconURL: nil,
                    price: "\(100 + $0)",
                    marketCap: "\(1_000_000 + $0 * 10_000)",
                    volume: "\(50_000 + $0 * 1_000)",
                    circulatingSupply: "\(1_000_000 + $0 * 5_000)",
                    ath: "\(200 + $0)",
                    atl: "\(10 + $0)",
                    change24h: "+\(10 + $0)",
                    isUp: true,
                    sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9],
                    description: "asdf",
                    externalLink: URL(string: "https://www.google.com")
                )
            }
        case .losers:
            return (1...20).map {
                CoinDetails(
                    id: "LOSE\($0)",
                    name: "Loser Coin \($0)",
                    symbol: "LOSE\($0)",
                    iconURL: nil,
                    price: "\(100 + $0)",
                    marketCap: "\(1_000_000 + $0 * 10_000)",
                    volume: "\(50_000 + $0 * 1_000)",
                    circulatingSupply: "\(1_000_000 + $0 * 5_000)",
                    ath: "\(200 + $0)",
                    atl: "\(10 + $0)",
                    change24h: "-\(10 + $0)",
                    isUp: false,
                    sparkline: [26.0, 22.1, 24.3, 19.5, 21.0, 16.4, 18.2, 12.0],
                    description: "asdf",
                    externalLink: URL(string: "https://www.google.com")
                )
            }
        }
    }
}
