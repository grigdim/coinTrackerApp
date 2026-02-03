//
//  SearchScreen.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 30/1/26.
//

import SwiftUI

struct SearchScreen: View {
    @EnvironmentObject private var stores: AppStores

    var body: some View {
        SearchView(
            viewModel: SearchViewModel(store: stores.markets)
        )
    }
}
