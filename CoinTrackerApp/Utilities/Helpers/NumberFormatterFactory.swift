import Foundation

enum NumberFormatterFactory {
    static func usdCurrency(
        locale: Locale = .current,
        minimumFractionDigits: Int = 0,
        maximumFractionDigits: Int = 2
    ) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter
    }

    static func decimal(
        locale: Locale = .current,
        minimumFractionDigits: Int = 0,
        maximumFractionDigits: Int = 16
    ) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter
    }
}
