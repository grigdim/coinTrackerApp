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
                    
                    // Only auto-paginate for Top 100 when the user is not searching.
                    let shouldPaginate = selectedCategory == .top100 && searchText.isEmpty

                    // When we reach the last ~5 rows, trigger loading the next page.
                    let thresholdIndex = filtered.index(filtered.endIndex, offsetBy: -5, limitedBy: filtered.startIndex) ?? filtered.startIndex


                    List {
                        ForEach(filtered.indices, id: \.self) { index in
                            let coin = filtered[index]
                            CoinRowView(coin: coin)
                                .onAppear {
                                    guard shouldPaginate else { return }
                                    if index >= thresholdIndex {
                                        Task {
                                            await viewModel.loadNextPage(category: selectedCategory)
                                        }
                                    }
                                }
                        }
                        
                        if shouldPaginate && viewModel.isLoadingNextPage {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
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
