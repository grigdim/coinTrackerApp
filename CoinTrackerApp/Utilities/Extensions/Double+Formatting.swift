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

    /// Accepts strings like "$282,142", "$847.2B", "12.5M" and returns raw value.
    static func parseMoneyToDouble(_ s: String) -> Double? {
        var text = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text != "—" else { return nil }

        // Support common abbreviation suffixes.
        let multipliers: [String: Double] = [
            "K": 1_000,
            "M": 1_000_000,
            "B": 1_000_000_000,
            "T": 1_000_000_000_000,
        ]
        var multiplier: Double = 1
        if let last = text.last {
            let suffix = String(last).uppercased()
            if let value = multipliers[suffix] {
                multiplier = value
                text.removeLast()
            }
        }

        // Strip currency symbols/whitespace but preserve signs and separators.
        let currencySymbols = CharacterSet(charactersIn: "$€£¥₩₹")
        let scalars =
            text
            .unicodeScalars
            .filter { !currencySymbols.contains($0) && !$0.properties.isWhitespace }
        let numberPart = String(String.UnicodeScalarView(scalars))
        guard !numberPart.isEmpty else { return nil }

        // Try locale-aware parse first (works for values produced by our formatters).
        let localFormatter = NumberFormatter()
        localFormatter.numberStyle = .decimal
        localFormatter.locale = .current
        if let parsed = localFormatter.number(from: numberPart)?.doubleValue {
            return parsed * multiplier
        }

        // Fallback for API-style strings with "," groupings regardless of locale.
        let fallback = numberPart.replacingOccurrences(of: ",", with: "")
        return Double(fallback).map { $0 * multiplier }
    }
}
