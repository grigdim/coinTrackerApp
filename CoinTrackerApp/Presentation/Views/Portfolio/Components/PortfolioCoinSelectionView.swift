//
//  PortfolioCoinSelectionView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct PortfolioCoinSelectionView: View {
    @StateObject private var marketViewModel: MarketOverviewViewModel
    @ObservedObject var portfolioViewModel: PortfolioViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    
    // CHANGED: We use this single state to control the sheet
    @State private var selectedCoin: CoinDetailsRoute?
    
    init(portfolioViewModel: PortfolioViewModel) {
        self.portfolioViewModel = portfolioViewModel
        let apiClient = APIClient()
        let repo = MarketRowRepositoryImpl(apiClient: apiClient)
        let useCase = GetMarketRowsUseCaseImpl(repository: repo)
        _marketViewModel = StateObject(wrappedValue: MarketOverviewViewModel(getMarketRows: useCase))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch marketViewModel.state {
                case .idle:
                    Color.clear.onAppear { Task { await marketViewModel.loadMarketRows(for: .top100) } }
                case .loading:
                    ProgressView("Loading Coins...")
                case .failed(let error):
                    VStack {
                        Text("Error loading coins").font(.headline)
                        Text(error.localizedDescription).font(.caption)
                        Button("Retry") { Task { await marketViewModel.loadMarketRows(for: .top100) } }
                    }
                case .loaded(let rows):
                    let filtered = rows.filter {
                        searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                    }
                    
                    if filtered.isEmpty {
                        VStack {
                            Image(systemName: "magnifyingglass").font(.largeTitle)
                            Text("No coins found")
                        }.foregroundColor(.secondary)
                    } else {
                        List(filtered) { row in
                            Button {
                                // ACTION: Simply setting this triggers the sheet
                                selectedCoin = CoinDetailsRoute(id: row.id, name: row.name, iconURL: row.iconURL)
                            } label: {
                                HStack {
                                    AsyncImage(url: row.iconURL) { img in img.resizable() } placeholder: { Circle().fill(.gray.opacity(0.3)) }
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading) {
                                        Text(row.name).font(.headline)
                                        Text(row.symbol.uppercased()).font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle.fill").foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search...")
            .navigationTitle("Select Asset")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
            // FIXED SHEET LOGIC:
            // This only activates if 'selectedCoin' is NOT nil.
            // It passes the safe, unwrapped 'coin' directly to the view.
            .sheet(item: $selectedCoin) { coin in
                AddHoldingView(viewModel: portfolioViewModel, coin: coin)
                    .presentationDetents([.medium])
            }
        }
    }
}
