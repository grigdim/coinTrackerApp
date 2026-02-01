//
//  alertType.swift
//  CoinTrackerApp
//
//  Created by vaitsis.vagias on 30/1/26.
//

enum AlertType: String, Codable, CaseIterable, Identifiable {
    case above, below, percentage

    var id: String { rawValue }
    var label: String {
        switch self {
        case .above: return Constants.ABOVE
        case .below: return Constants.BELOW
        case .percentage: return Constants.PERCENTAGE
        }
    }
}
