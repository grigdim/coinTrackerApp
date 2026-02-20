//
//  BuildConfig.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation

enum BuildConfig {
    static var coinGeckoAPIKey: String? {
        if let envKey = ProcessInfo.processInfo.environment["COINGECKO_API_KEY"],
            !envKey.isEmpty
        {
            return envKey
        }

        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "COINGECKO_API_KEY")
            as? String,
            !plistKey.isEmpty
        {
            return plistKey
        }

        return nil
    }
}
