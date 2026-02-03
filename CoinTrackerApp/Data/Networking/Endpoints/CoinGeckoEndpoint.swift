//
//  CoinGeckoEndpoint.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

enum CoinGeckoEndpoint {
    // Definition: perPage, page, then ids
    case markets(category: String, perPage: Int, page: Int, ids: [String]?)
    case categoriesList
    case trending
    case coinDetail(id: String)
    case history(id: String, days: String)
    case search(query: String)

    var baseURL: String { "https://api.coingecko.com/api/v3" }

    var path: String {
        switch self {
        case .categoriesList: return "/coins/categories/list"
        case .markets: return "/coins/markets"
        case .trending: return "/search/trending"
        case .coinDetail(let id): return "/coins/\(id)"
        case .history(let id, _): return "/coins/\(id)/market_chart"
        case .search: return "/search"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .markets(let category, let perPage, let page, let ids):
            var query: [URLQueryItem] = [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "market_category", value: "\(category)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "sparkline", value: "true"),
                URLQueryItem(name: "price_change_percentage", value: "24h"),
            ]

            if let ids = ids, !ids.isEmpty {
                let idsString = ids.joined(separator: ",")
                query.append(URLQueryItem(name: "ids", value: idsString))
            }

            return query

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
        case .trending, .categoriesList:
            return []
        }
    }

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
