//
//  MarketOverviewView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct MarketOverviewView: View {
    @StateObject private var viewModel = MarketOverviewViewModel()

    // Which market category is selected (Top 100, Trending, etc.)
    @State private var selectedCategory: MarketCategory = .top100

    // Search text from the searchable UI
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 0) {

            // Segmented control for category switching
            Picker("Category", selection: $selectedCategory) {
                ForEach(MarketCategory.allCases) { category in
                    Text(category.rawValue)
                        .tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedCategory) { newValue in
                Task { await viewModel.refresh(category: newValue) }
            }

            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .failed(let error):
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)

                        Text("Couldn’t load markets")
                            .font(.headline)

                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()

                case .loaded(let coins):
                    let filtered = coins.filter {
                        searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                    }

                    List {
                        ForEach(filtered) { coin in
                            CoinRowView(coin: coin)
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search coins")
                    .refreshable {
                        await viewModel.refresh(category: selectedCategory)
                    }
                }
            }
        }
        .task {
            await viewModel.load(category: selectedCategory)
        }
    }
}

#Preview {
    MarketOverviewView()
}
