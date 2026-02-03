//
//  MarketOverviewScreen.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 30/1/26.
//

import SwiftUI

struct MarketOverviewScreen: View {
    @EnvironmentObject private var stores: AppStores

    var body: some View {
        MarketOverviewView(
            viewModel: MarketOverviewViewModel(store: stores.markets)
        )
    }
}
