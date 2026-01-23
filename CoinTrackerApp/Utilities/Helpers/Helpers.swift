//
//  Helpers.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 23/1/26.
//

import Foundation

func isStale(_ fetchedAt: Date, cacheTTL: TimeInterval) -> Bool {
    Date().timeIntervalSince(fetchedAt) > cacheTTL
}

struct Cached<Value> {
    let value: Value
    let fetchedAt: Date
}
