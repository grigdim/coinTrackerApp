//
//  ChartRange.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 22/1/26.
//

import Foundation

enum ChartRange: CaseIterable, Identifiable {
    case day
    case week
    case month
    case year

    var id: Self { self }

    /// UI label
    var label: String {
        switch self {
        case .day: return "24H"
        case .week: return "7D"
        case .month: return "30D"
        case .year: return "1Y"
        }
    }

    /// API value
    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}
