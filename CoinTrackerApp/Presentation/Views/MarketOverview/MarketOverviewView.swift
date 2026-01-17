//
//  MarketOverviewView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

private struct CoinDetailsRoute: Hashable {
    let id: String
    let name: String
}

private struct MarketOverviewNoSearchResultsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No results")
                .font(.headline)
            
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

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
            
            ScrollViewReader { proxy in
                ScrollView {
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
                                
                                Button("Retry") {
                                    Task {
                                        await viewModel.refresh(for: selectedCategory)
                                    }
                                }
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
                            
                            LazyVStack (spacing: 0) {
                                ForEach(Array(filtered.enumerated()), id: \.element.id) { index, coin in
                                    NavigationLink(value: CoinDetailsRoute(id: coin.id, name: coin.name)) {
                                        CoinRowView(coin: coin)
                                            .onAppear {
                                                guard shouldPaginate else { return }
                                                if index >= thresholdIndex {
                                                    Task {
                                                        await viewModel.loadNextPage(for: selectedCategory)
                                                    }
                                                }
                                            }
                                            .background(
                                                GeometryReader{ geo in
                                                    Color.clear.preference(
                                                        key: RowOffsetKey.self,
                                                        value: [coin.id: geo.frame(in: .named("marketScrolled")).minY]
                                                    )
                                                }
                                            )
                                    }
                                    .id(coin.id)
                                    
                                    Divider()
                                }
                                
                                if shouldPaginate && viewModel.isLoadingNextPage {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                }
                            }
                            .overlay {
                                if filtered.isEmpty {
                                    MarketOverviewNoSearchResultsView()
                                }
                            }
                        }
                }
                .padding()
                .searchable(text: $searchText, prompt: "Search coins")
                .refreshable {
                    await viewModel.refresh(for: selectedCategory)
                }

                .onChange(of: selectedCategory) { newValue in
                    Task {
                        await viewModel.load(for: newValue)
                        if let anchor = viewModel.scrollToAnchor(for: newValue) {
                            try? await Task.sleep(nanoseconds:50_000_000)
                            proxy.scrollTo(anchor, anchor: .top)
                        }
                    }
                }
                .coordinateSpace(name: "marketScrolled")
                .onPreferenceChange(RowOffsetKey.self) { offsets in
                    let visible = offsets.filter { $0.value >= 0 }
                    if let topMost = visible.min(by: { $0.value < $1.value })?.key {
                        viewModel.saveScrolledAnchor(for: selectedCategory, id: topMost)
                    }
                }
            }
        }
        .task {
            await viewModel.load(for: selectedCategory)
        }
        .navigationDestination(for: CoinDetailsRoute.self){ route in
            CoinDetailsView()
                .navigationTitle(route.name)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MarketOverviewView()
}
