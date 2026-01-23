//
//  ChartMapper.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

struct ChartDataMapper {
    static func map(dto: ChartDataDTO) -> [CoinChartPoint] {
        dto.prices.compactMap { item in
            guard item.count == 2 else { return nil }

            let timestamp: TimeInterval = item[0] / 1000
            let value = item[1]

            return CoinChartPoint(
                date: Date(timeIntervalSince1970: timestamp),
                value: value
            )
        }
        .sorted {
            $0.date < $1.date
        }
    }
}
