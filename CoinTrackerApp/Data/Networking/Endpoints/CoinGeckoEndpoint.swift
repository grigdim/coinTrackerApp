//
//  CoinGeckoEndpoint.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation


enum CoinGeckoEndpoint {
    case markets(currency: String, perPage: Int, page: Int)
    case trending
    case coinDetail(id: String)
    case history(id: String, days: String)
    case search(query: String)

    var baseURL: String { "https://api.coingecko.com/api/v3" }

    var path: String {
        switch self {
        case .markets: return "/coins/markets" //done
        case .trending: return "/search/trending" //done
        case .coinDetail(let id): return "/coins/\(id)" //done
        case .history(let id, _): return "/coins/\(id)/market_chart" //done
        case .search: return "/search" //search is used for multiple cases, such as trending
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .markets(let currency, let perPage, let page):
            return [
                URLQueryItem(name: "vs_currency", value: currency),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "sparkline", value: "true"),
                URLQueryItem(name: "price_change_percentage", value: "24h")
            ]
        case .history(_, let days):
            return [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "days", value: days)
            ]
        case .search(let query):
            return [URLQueryItem(name: "query", value: query)]
        default:
            return []
        }
    }

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
