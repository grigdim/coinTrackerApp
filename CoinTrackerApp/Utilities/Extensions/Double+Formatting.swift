import Foundation

enum AbbreviatedNumberFormatter {
    static func format(_ value: Double) -> String {
        let absValue = abs(value)

        let sign = value < 0 ? "-" : ""

        switch absValue {
        case 1_000_000_000_000...:
            return "\(sign)\(formatAbbreviated(absValue / 1_000_000_000_000))T"
        case 1_000_000_000...:
            return "\(sign)\(formatAbbreviated(absValue / 1_000_000_000))B"
        case 1_000_000...:
            return "\(sign)\(formatAbbreviated(absValue / 1_000_000))M"
        case 1_000...:
            return "\(sign)\(formatAbbreviated(absValue / 1_000))K"
        default:
            return "\(sign)\(Int(absValue))"
        }
    }

    private static func formatAbbreviated(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.maximumFractionDigits = value < 10 ? 2 : 1
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

enum CurrencyFormatter {
    static func usd(_ value: Double?) -> String {
        guard let value else { return "—" }

        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0

        return formatter.string(from: NSNumber(value: value)) ?? "—"
    }

    static func usdAbbreviated(_ value: Double?) -> String {
        guard let value else { return "—" }
        let symbol = Locale.current.currencySymbol ?? "$"
        return symbol + AbbreviatedNumberFormatter.format(value)
    }
}

enum PercentFormatter {
    static func twoDecimals(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.2f%%", locale: .current, value)
    }

    static func parse(_ value: String?) -> Double? {
        guard let value else { return nil }
        let cleaned =
            value
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: "+", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Double(cleaned)
    }
}

enum NumberFormatterUtil {
    static func abbreviated(_ value: Double?) -> String {
        guard let value else { return "—" }
        return AbbreviatedNumberFormatter.format(value)
    }
}

enum MoneyStringFormatter {
    /// Accepts strings like "$99,703,583" and returns "99.7M" (no $) or "—"
    static func abbreviatedUSDString(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "—" }
        let number = parseMoneyToDouble(value)
        guard let number else { return value }
        let symbol = Locale.current.currencySymbol ?? "$"
        return symbol + AbbreviatedNumberFormatter.format(number)
    }

    /// Accepts strings like "$282,142" and returns "$282K" etc.
    static func parseMoneyToDouble(_ s: String) -> Double? {
        // keep digits and dot only
        let cleaned =
            s
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Double(cleaned)
    }
}
