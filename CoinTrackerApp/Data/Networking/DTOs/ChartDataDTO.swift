//
//  ChartDataDTO.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 22/1/26.
//

import Foundation

struct ChartDataDTO: Decodable {
    let prices: [[Double]]
    let marketCaps: [[Double]]?
    let totalVolumes: [[Double]]?

    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}
