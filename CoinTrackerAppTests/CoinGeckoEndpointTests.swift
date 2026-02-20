import XCTest
@testable import CoinTrackerApp

final class CoinGeckoEndpointTests: XCTestCase {
    func testMarketsEndpointOmitsCategoryWhenEmpty() {
        let endpoint = CoinGeckoEndpoint.markets(
            category: "",
            perPage: 25,
            page: 1,
            ids: nil
        )

        let queryNames = Set(endpoint.queryItems.map(\.name))
        XCTAssertFalse(queryNames.contains("category"))
    }

    func testMarketsEndpointIncludesCategoryWhenProvided() {
        let endpoint = CoinGeckoEndpoint.markets(
            category: "layer-1",
            perPage: 25,
            page: 1,
            ids: nil
        )

        let categoryValue = endpoint.queryItems.first(where: { $0.name == "category" })?.value
        XCTAssertEqual(categoryValue, "layer-1")
    }

    func testMarketsEndpointJoinsIdsInSingleQueryItem() {
        let endpoint = CoinGeckoEndpoint.markets(
            category: "",
            perPage: 25,
            page: 1,
            ids: ["bitcoin", "ethereum"]
        )

        let idsValue = endpoint.queryItems.first(where: { $0.name == "ids" })?.value
        XCTAssertEqual(idsValue, "bitcoin,ethereum")
    }
}
