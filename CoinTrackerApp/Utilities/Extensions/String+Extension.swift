//
//  String+Extension.swift
//  CoinTrackerApp
//
//  Created by antonis.darmis on 30/1/26.
//
import Foundation

extension String {
    var asCurrencyDouble: Double {
        // 1. Remove everything that is NOT a number or a dot (removes $, currency symbols, commas)
        // Note: This assumes USD format (1,000.00).
        let cleaned = self.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. Convert to Double
        return Double(cleaned) ?? 0.0
    }
}
