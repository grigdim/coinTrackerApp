//
//  CoinGeckoEndpoint.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

enum CoinGeckoEndpoint {
    case markets(perPage: Int, page: Int)
    case trending
    case coinDetail(id: String)
    case history(id: String, days: String)
    case search(query: String)

    var baseURL: String { "https://api.coingecko.com/api/v3" }

    var path: String {
        switch self {
        case .markets: return "/coins/markets"
        case .trending: return "/search/trending"
        case .coinDetail(let id): return "/coins/\(id)"
        case .history(let id, _): return "/coins/\(id)/market_chart"
        case .search: return "/search"  //search is used for multiple cases, such as trending
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .markets(let perPage, let page):
            return [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "sparkline", value: "true"),
                URLQueryItem(name: "price_change_percentage", value: "24h"),
            ]
        case .history(_, let days):
            return [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "days", value: days),
                URLQueryItem(name: "precision", value: "full"),
            ]
        case .coinDetail:
            return [
                URLQueryItem(name: "localization", value: "false"),
                URLQueryItem(name: "tickers", value: "false"),
                URLQueryItem(name: "market_data", value: "true"),
                URLQueryItem(name: "community_data", value: "false"),
                URLQueryItem(name: "developer_data", value: "false"),
                URLQueryItem(name: "sparkline", value: "false"),
            ]
        case .search(let query):
            return [URLQueryItem(name: "query", value: query)]
        case .trending:
            return []
        }
    }

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
