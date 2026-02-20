import XCTest
@testable import CoinTrackerApp

@MainActor
final class PortfolioAndWatchlistsViewModelTests: XCTestCase {
    private let portfolioKey = "saved_portfolio"
    private let coinListKey = "cached_coin_list"
    private let watchlistsKey = "saved_watchlists"

    override func setUp() {
        super.setUp()
        clearPersistence()
    }

    override func tearDown() {
        clearPersistence()
        super.tearDown()
    }

    func testAddTransactionUsesRouteSymbolForNewAsset() {
        let viewModel = PortfolioViewModel(repository: StubMarketRowRepository())
        let route = CoinDetailsRoute(
            id: "bitcoin",
            name: "Bitcoin",
            symbol: "BTC",
            iconURL: nil
        )

        viewModel.addTransaction(coin: route, price: 100, quantity: 2)

        XCTAssertEqual(viewModel.assets.count, 1)
        XCTAssertEqual(viewModel.assets.first?.id, "bitcoin")
        XCTAssertEqual(viewModel.assets.first?.symbol, "BTC")
        XCTAssertEqual(viewModel.assets.first?.transactions.count, 1)
    }

    func testAddTransactionAppendsToExistingAsset() {
        let viewModel = PortfolioViewModel(repository: StubMarketRowRepository())
        let route = CoinDetailsRoute(
            id: "bitcoin",
            name: "Bitcoin",
            symbol: "BTC",
            iconURL: nil
        )

        viewModel.addTransaction(coin: route, price: 100, quantity: 1)
        viewModel.addTransaction(coin: route, price: 110, quantity: 0.5)

        XCTAssertEqual(viewModel.assets.count, 1)
        XCTAssertEqual(viewModel.assets.first?.transactions.count, 2)
    }

    func testWatchlistsViewModelPersistsAndReordersLists() {
        let writer = WatchlistsViewModel()
        writer.addWatchlist(name: "First", icon: "1.circle")
        writer.addWatchlist(name: "Second", icon: "2.circle")
        writer.moveWatchlist(from: IndexSet(integer: 0), to: 2)

        let reader = WatchlistsViewModel()
        reader.loadData()

        XCTAssertEqual(reader.watchlists.map(\.name), ["Second", "First"])

        reader.deleteWatchlist(at: IndexSet(integer: 1))
        XCTAssertEqual(reader.watchlists.map(\.name), ["Second"])
    }

    func testLegacyWatchlistSnapshotsDecodeToCoinIDs() throws {
        struct LegacyWatchlist: Codable {
            let id: UUID
            let name: String
            let icon: String
            let coins: [CoinDetails]
        }

        let legacy = LegacyWatchlist(
            id: UUID(),
            name: "Legacy",
            icon: "star.fill",
            coins: [
                CoinDetails.sampleCoins[0],
                CoinDetails.sampleCoins[1],
                CoinDetails.sampleCoins[0],
            ]
        )

        let data = try JSONEncoder().encode(legacy)
        let decoded = try JSONDecoder().decode(Watchlist.self, from: data)

        XCTAssertEqual(decoded.coinIDs, ["bitcoin", "ethereum"])
    }

    func testWatchlistEncodesCoinIDsOnly() throws {
        let watchlist = Watchlist(
            id: UUID(),
            name: "IDs Only",
            icon: "list.bullet",
            coinIDs: ["bitcoin", "ethereum"]
        )

        let data = try JSONEncoder().encode(watchlist)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        XCTAssertNotNil(json["coinIDs"])
        XCTAssertNil(json["coins"])
    }

    private func clearPersistence() {
        CodablePersistence.removeUserDefaultsValue(for: portfolioKey)
        CodablePersistence.removeUserDefaultsValue(for: coinListKey)
        CodablePersistence.removeUserDefaultsValue(for: watchlistsKey)
    }
}

private final class StubMarketRowRepository: MarketRowRepository {
    var rows: [MarketRow]

    init(rows: [MarketRow] = []) {
        self.rows = rows
    }

    func fetchMarketRows(
        category: String,
        perPage: Int,
        page: Int,
        ids: [String]?
    ) async throws -> [MarketRow] {
        rows
    }
}
