import XCTest
@testable import CoinTrackerApp

@MainActor
final class AlertStoreBehaviorTests: XCTestCase {
    private var filenamesToCleanup: [String] = []

    override func tearDown() {
        for filename in filenamesToCleanup {
            try? FileManager.default.removeItem(at: fileURL(for: filename))
        }
        filenamesToCleanup.removeAll()
        super.tearDown()
    }

    func testEvaluateAlertsRespectsTypesAndThresholds() {
        let store = makeStore()
        let now = Date()

        let above = makeAlert(
            coinId: "bitcoin",
            target: 100,
            type: .above,
            createdAt: now
        )
        let below = makeAlert(
            coinId: "bitcoin",
            target: 80,
            type: .below,
            createdAt: now
        )
        let percentage = makeAlert(
            coinId: "bitcoin",
            target: 5,
            type: .percentage,
            createdAt: now
        )

        store.add(above)
        store.add(below)
        store.add(percentage)

        let triggered = store.evaluateAlerts(
            coinId: "bitcoin",
            latestPrice: 110,
            baselinePriceForPercentage: 100
        )

        XCTAssertEqual(Set(triggered.map(\.id)), Set([above.id, percentage.id]))
    }

    func testEvaluatePercentageRequiresBaseline() {
        let store = makeStore()
        let percentage = makeAlert(
            coinId: "bitcoin",
            target: 5,
            type: .percentage,
            createdAt: Date()
        )
        store.add(percentage)

        let triggeredWithoutBaseline = store.evaluateAlerts(
            coinId: "bitcoin",
            latestPrice: 110,
            baselinePriceForPercentage: nil
        )

        XCTAssertTrue(triggeredWithoutBaseline.isEmpty)
    }

    func testPersistsActiveAndHistoryAcrossStoreInstances() {
        let filename = "alerts-tests-\(UUID().uuidString).json"
        filenamesToCleanup.append(filename)
        try? FileManager.default.removeItem(at: fileURL(for: filename))

        let createdAt = Date(timeIntervalSince1970: 1000)
        let triggeredAt = Date(timeIntervalSince1970: 2000)
        let alert = makeAlert(
            coinId: "ethereum",
            target: 2000,
            type: .above,
            createdAt: createdAt
        )

        let writer = AlertStore(filename: filename)
        writer.add(alert)
        writer.archiveToHistory(
            alertId: alert.id,
            triggeredAt: triggeredAt,
            markUnread: true
        )

        let reader = AlertStore(filename: filename)
        XCTAssertTrue(reader.active.isEmpty)
        XCTAssertEqual(reader.history.count, 1)
        XCTAssertEqual(reader.history.first?.id, alert.id)
        XCTAssertEqual(reader.history.first?.triggeredAt, triggeredAt)
        XCTAssertEqual(reader.unreadHistoryCount, 1)
    }

    private func makeStore() -> AlertStore {
        let filename = "alerts-tests-\(UUID().uuidString).json"
        filenamesToCleanup.append(filename)
        try? FileManager.default.removeItem(at: fileURL(for: filename))
        return AlertStore(filename: filename)
    }

    private func fileURL(for filename: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    private func makeAlert(
        coinId: String,
        target: Double,
        type: AlertType,
        createdAt: Date
    ) -> CoinPriceAlert {
        CoinPriceAlert(
            id: UUID(),
            coinId: coinId,
            targetPrice: target,
            type: type,
            isEnabled: true,
            createdAt: createdAt,
            triggeredAt: nil,
            isUnread: false
        )
    }
}
