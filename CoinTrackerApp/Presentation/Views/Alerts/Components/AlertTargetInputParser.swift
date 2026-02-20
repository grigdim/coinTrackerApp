import Foundation

enum AlertTargetInputParser {
    static func validationError(for input: String, locale: Locale = .current)
        -> String?
    {
        // Allow empty while drafting.
        guard !input.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        let decimalSeparator = formatter.decimalSeparator ?? "."

        var seenDecimal = false
        for ch in input {
            if ch.isNumber { continue }
            if String(ch) == decimalSeparator, !seenDecimal {
                seenDecimal = true
                continue
            }
            return
                "Only numbers\(decimalSeparator == "." ? " and a single dot" : " and a single decimal separator") are allowed."
        }

        return nil
    }

    static func parse(_ input: String, locale: Locale = .current) -> Double? {
        var text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        // Remove common currency symbols and spaces.
        let unwantedChars = CharacterSet(charactersIn: "$€£¥  ")
        text = text.components(separatedBy: unwantedChars).joined()

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale

        // Remove grouping separators (e.g. "," or ".").
        if let grouping = formatter.groupingSeparator, !grouping.isEmpty {
            text = text.replacingOccurrences(of: grouping, with: "")
        }

        // Normalize decimal separator to ".".
        let decimal = formatter.decimalSeparator ?? "."
        if decimal != "." {
            text = text.replacingOccurrences(of: decimal, with: ".")
        }

        // Allow only digits and a single dot.
        var cleaned = ""
        var seenDot = false
        for ch in text {
            if ch.isNumber {
                cleaned.append(ch)
            } else if ch == ".", !seenDot {
                cleaned.append(ch)
                seenDot = true
            }
        }

        guard !cleaned.isEmpty else { return nil }
        return Double(cleaned)
    }
}
