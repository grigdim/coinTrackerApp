//
//  MarketOverviewNoSearchResultsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 27/1/26.
//

import SwiftUI

public struct NoSearchResultsView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text("No results")
                .font(.headline)
            Text("Try a different search.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoSearchResultsView()
}

