import XCTest
@testable import CoinTrackerApp

final class PercentFormatterTests: XCTestCase {
    func testParsePositivePercentString() {
        XCTAssertEqual(PercentFormatter.parse("+2.45%"), 2.45, accuracy: 0.0001)
    }

    func testParseNegativePercentString() {
        XCTAssertEqual(PercentFormatter.parse("-1.10%"), -1.10, accuracy: 0.0001)
    }

    func testParseReturnsNilForInvalidInput() {
        XCTAssertNil(PercentFormatter.parse("abc"))
        XCTAssertNil(PercentFormatter.parse(nil))
    }
}
