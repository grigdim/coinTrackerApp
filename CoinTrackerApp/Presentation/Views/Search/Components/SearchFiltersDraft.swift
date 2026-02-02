//
//  SearchFiltersDraft.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 31/1/26.
//

struct SearchFiltersDraft: Equatable {
    var filters: SearchFilters
    var categoryId: String
}

extension SearchFiltersDraft {
    static func `default`(categoryId: String = "layer-1") -> Self {
        .init(filters: .default, categoryId: categoryId)
    }
}
