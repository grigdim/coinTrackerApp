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
        formatter.maximumFractionDigits = value < 10 ? 2 : 1
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
