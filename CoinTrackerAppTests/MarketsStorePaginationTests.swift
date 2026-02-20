import XCTest
@testable import CoinTrackerApp

@MainActor
final class MarketsStorePaginationTests: XCTestCase {
    func testLoadNextPageMergesAndDedupesByID() async throws {
        let useCase = StubGetMarketRowsUseCase(
            responsesByCategoryAndPage: [
                "layer-1": [
                    1: [makeRow(id: "bitcoin"), makeRow(id: "ethereum")],
                    2: [makeRow(id: "ethereum"), makeRow(id: "solana")],
                ]
            ]
        )
        let store = MarketsStore(getMarketRows: useCase)

        _ = try await store.refresh(
            cacheKey: "Top 100",
            requestCategory: "layer-1",
            perPage: 10
        )
        let merged = try await store.loadNextPage(
            cacheKey: "Top 100",
            requestCategory: "layer-1",
            perPage: 10
        )

        XCTAssertEqual(merged.map(\.id), ["bitcoin", "ethereum", "solana"])
        XCTAssertEqual(useCase.calls.map(\.page), [1, 2])
    }

    func testPaginationStateIsIsolatedPerCacheKey() async throws {
        let useCase = StubGetMarketRowsUseCase(
            responsesByCategoryAndPage: [
                "layer-1": [
                    1: [makeRow(id: "bitcoin")],
                    2: [makeRow(id: "ethereum")],
                ]
            ]
        )
        let store = MarketsStore(getMarketRows: useCase)

        _ = try await store.refresh(
            cacheKey: "Top 100",
            requestCategory: "layer-1",
            perPage: 10
        )
        _ = try await store.refresh(
            cacheKey: "Gainers",
            requestCategory: "layer-1",
            perPage: 250
        )

        _ = try await store.loadNextPage(
            cacheKey: "Top 100",
            requestCategory: "layer-1",
            perPage: 10
        )
        _ = try await store.loadNextPage(
            cacheKey: "Gainers",
            requestCategory: "layer-1",
            perPage: 250
        )

        XCTAssertEqual(useCase.calls.map(\.page), [1, 1, 2, 2])
        XCTAssertEqual(store.cachedRows(for: "Top 100").count, 2)
        XCTAssertEqual(store.cachedRows(for: "Gainers").count, 2)
    }

    private func makeRow(id: String) -> MarketRow {
        MarketRow(
            id: id,
            name: id.capitalized,
            symbol: String(id.prefix(3)).uppercased(),
            iconURL: nil,
            price: "$1.00",
            priceRaw: 1,
            marketCap: "$1M",
            marketCapRaw: 1_000_000,
            volume: "$10K",
            volumeRaw: 10_000,
            circulatingSupply: "1M",
            ath: "$2.00",
            atl: "$0.10",
            change24h: "+1.0%",
            change24hRaw: 1,
            isUp: true,
            sparkline: [1, 1.1, 1.2],
            currentPriceRaw: 1
        )
    }
}

private final class StubGetMarketRowsUseCase: GetMarketRowsUseCase {
    struct Call {
        let category: String
        let perPage: Int
        let page: Int
        let ids: [String]?
    }

    private let responsesByCategoryAndPage: [String: [Int: [MarketRow]]]
    private(set) var calls: [Call] = []

    init(responsesByCategoryAndPage: [String: [Int: [MarketRow]]]) {
        self.responsesByCategoryAndPage = responsesByCategoryAndPage
    }

    func execute(
        category: String,
        perPage: Int,
        page: Int,
        ids: [String]?
    ) async throws -> [MarketRow] {
        calls.append(
            Call(
                category: category,
                perPage: perPage,
                page: page,
                ids: ids
            )
        )
        return responsesByCategoryAndPage[category]?[page] ?? []
    }
}
