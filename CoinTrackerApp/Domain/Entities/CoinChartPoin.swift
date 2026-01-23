//
//  CoinChartPoin.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 22/1/26.
//

import Foundation

struct CoinChartPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
