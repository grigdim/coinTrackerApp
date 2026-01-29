//
//  SearchViewModel.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var state: ViewState<[MarketRow]> = .idle
    init(initial: [MarketRow]) {
        self.state = .loaded(initial)
    }
}
