//
//  AppStores.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 30/1/26.
//

import Combine
import SwiftUI

@MainActor
final class AppStores: ObservableObject {

    let markets: MarketsStore
    let categories: CategoriesStore

    init() {
        let apiClient = APIClient()

        markets = MarketsStore(
            getMarketRows: GetMarketRowsUseCaseImpl(
                repository: MarketRowRepositoryImpl(apiClient: apiClient)
            )
        )

        categories = CategoriesStore(
            getCategories: GetCategoriesUseCaseImpl(
                repository: CategoriesRepositoryImpl(apiClient: apiClient)
            )
        )
    }
}
