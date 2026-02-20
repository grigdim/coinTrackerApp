import XCTest
@testable import CoinTrackerApp

final class MoneyStringFormatterTests: XCTestCase {
    func testParseMoneyHandlesAbbreviatedBillions() {
        XCTAssertEqual(
            MoneyStringFormatter.parseMoneyToDouble("$847.2B"),
            847_200_000_000,
            accuracy: 0.001
        )
    }

    func testParseMoneyHandlesGroupedIntegers() {
        XCTAssertEqual(
            MoneyStringFormatter.parseMoneyToDouble("$99,703,583"),
            99_703_583,
            accuracy: 0.001
        )
    }

    func testParseMoneyHandlesMillionsAndThousands() {
        XCTAssertEqual(
            MoneyStringFormatter.parseMoneyToDouble("12.5M"),
            12_500_000,
            accuracy: 0.001
        )
        XCTAssertEqual(
            MoneyStringFormatter.parseMoneyToDouble("€1.2K"),
            1_200,
            accuracy: 0.001
        )
    }

    func testParseMoneyReturnsNilForUnavailableValue() {
        XCTAssertNil(MoneyStringFormatter.parseMoneyToDouble("—"))
    }
}
