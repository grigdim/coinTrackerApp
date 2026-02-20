import XCTest
@testable import CoinTrackerApp

final class AlertTargetInputParserTests: XCTestCase {
    func testValidationErrorRejectsInvalidCharacters() {
        let error = AlertTargetInputParser.validationError(
            for: "12a.4",
            locale: Locale(identifier: "en_US")
        )

        XCTAssertNotNil(error)
    }

    func testValidationErrorAllowsSingleDecimalSeparator() {
        let error = AlertTargetInputParser.validationError(
            for: "12.45",
            locale: Locale(identifier: "en_US")
        )

        XCTAssertNil(error)
    }

    func testParseHandlesUSDCurrencyInput() {
        let value = AlertTargetInputParser.parse(
            "$1,234.56",
            locale: Locale(identifier: "en_US")
        )

        XCTAssertEqual(value, 1_234.56, accuracy: 0.0001)
    }

    func testParseHandlesLocaleDecimalSeparator() {
        let value = AlertTargetInputParser.parse(
            "1 234,56€",
            locale: Locale(identifier: "fr_FR")
        )

        XCTAssertEqual(value, 1_234.56, accuracy: 0.0001)
    }
}
