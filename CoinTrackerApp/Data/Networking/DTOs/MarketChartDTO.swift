//
//  MarketChartDTO.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

// DTO for /coins/{id}/market_chart endpoint
struct MarketChartDTO: Codable {
    let prices: [[Double]] // Each element is [timestamp, price]
    let marketCaps: [[Double]] // Each element is [timestamp, marketCap]
    let totalVolumes: [[Double]] // Each element is [timestamp, volume]
}
