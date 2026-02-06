//
//  PortfolioCoinSelectionView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct PortfolioCoinSelectionView: View {
    @EnvironmentObject var viewModel: PortfolioViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCoin: CoinDetailsRoute?
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.searchState {
                case .idle:
                    Color.clear.onAppear {
                        Task { await viewModel.loadAvailableCoins() }
                    }
                    
                case .loading:
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading Coins...")
                            .foregroundColor(.secondary)
                    }
                    
                case .failed(let error):
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Failed to load list")
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Retry") {
                            Task { await viewModel.loadAvailableCoins() }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                case .loaded:
                    if viewModel.filteredCoins.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No coins found")
                                .font(.headline)
                        }
                    } else {
                        List(viewModel.filteredCoins) { row in
                            Button {
                                selectedCoin = CoinDetailsRoute(id: row.id, name: row.name, iconURL: row.iconURL)
                            } label: {
                                HStack {
                                    AsyncImage(url: row.iconURL) { img in
                                        img.resizable()
                                    } placeholder: {
                                        Circle().fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(row.name)
                                            .font(.headline)
                                        Text(row.symbol.uppercased())
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // FIXED: Removed 'if let'. Display the Double directly.
                                    Text(row.currentPriceRaw.formatted(.currency(code: "USD")))
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
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
            .searchable(text: $viewModel.searchText, prompt: "Search Bitcoin, Ethereum...")
            .navigationTitle("Select Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(item: $selectedCoin) { coin in
                AddHoldingView(viewModel: _viewModel, coin: coin)
                    .presentationDetents([.medium])
            }
        }
    }
}

