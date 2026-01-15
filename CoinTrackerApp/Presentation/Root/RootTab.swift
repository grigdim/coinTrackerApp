//
//  RootTab.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

enum RootTab: Hashable {
    case markets
    case search
    case portfolio
    case watchlists
    case alerts
    
    var title: String {
        switch self {
        case .markets: return "Markets"
        case .search: return "Search"
        case .portfolio: return "Portfolio"
        case .watchlists: return "Watchlists"
        case .alerts: return "Alerts"
        }
    }
    
    var systemImage: String {
        switch self {
        case .markets: return "chart.line.uptrend.xyaxis"
        case .search: return "magnifyingglass"
        case .portfolio: return "briefcase"
        case .watchlists: return "star"
        case .alerts: return "bell"
        }
    }
}
