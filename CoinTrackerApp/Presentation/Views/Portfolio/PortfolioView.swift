//
//  PortfolioView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct PortfolioView: View {
    @StateObject private var viewModel: PortfolioViewModel
    @State private var showingAddSheet = false
    
    init(viewModel: PortfolioViewModel? = nil) {
        if let vm = viewModel {
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            let apiClient = APIClient()
            let repo = MarketRowRepositoryImpl(apiClient: apiClient)
            _viewModel = StateObject(wrappedValue: PortfolioViewModel(repository: repo))
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 2. Balance Card
                balanceCard
                
                if !viewModel.assets.isEmpty {
                    // 3. Distribution Chart
                    VStack(alignment: .leading) {
                        Text("Allocation")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            PortfolioPieChart(assets: viewModel.assets)
                                .frame(height: 180)
                            
                            legendView
                        }
                        .padding(.horizontal)
                    }
                    
                    // 4. Assets List
                    VStack(alignment: .leading) {
                        Text("Assets")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.assets) { asset in
                                NavigationLink(value: asset) {
                                    AssetRow(asset: asset)
                                }
                                .buttonStyle(.plain) // Keeps row interactive but without blue tint
                                Divider()
                            }
                            .onDelete(perform: viewModel.deleteAsset)
                        }
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                } else {
                    emptyState
                }
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Portfolio")
        // 5. Handling Navigation Destination for the History View
        .navigationDestination(for: PortfolioAsset.self) { asset in
            TransactionHistoryView(asset: asset)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        // 6. Sheet for Searching/Adding Coins
        .sheet(isPresented: $showingAddSheet) {
            PortfolioCoinSelectionView(viewModel: viewModel)
        }
        // 7. Data Refreshing
        .refreshable {
            await viewModel.refreshPortfolioPrices()
        }
        .task {
            // Refresh prices every time view appears to keep P/L up to date
            await viewModel.refreshPortfolioPrices()
        }
    }
    
    // MARK: - Subviews
    
    private var balanceCard: some View {
        VStack(spacing: 10) {
            Text("Total Balance")
                .foregroundColor(.secondary)
            
            Text(viewModel.totalValue.formatted(.currency(code: "USD")))
                .font(.system(size: 34, weight: .bold))
            
            HStack {
                let pnl = viewModel.totalProfitLoss
                Image(systemName: pnl >= 0 ? "arrow.up.right" : "arrow.down.right")
                
                Text(pnl.formatted(.currency(code: "USD")))
                
                Text("(\(viewModel.totalProfitLossPercentage.formatted(.number.precision(.fractionLength(2))))%)")
            }
            .foregroundColor(viewModel.totalProfitLoss >= 0 ? .green : .red)
            .padding(8)
            .background(
                Capsule()
                    .fill(viewModel.totalProfitLoss >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 4) {
            let colors: [Color] = [.blue, .purple, .pink, .orange, .yellow, .green, .cyan, .indigo]
            // Show top 5 assets in legend
            ForEach(Array(viewModel.assets.prefix(5).enumerated()), id: \.element.id) { index, asset in
                HStack {
                    Circle()
                        .fill(colors[index % colors.count])
                        .frame(width: 8, height: 8)
                    Text(asset.id.capitalized)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.pie")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No assets yet")
                .font(.headline)
            Text("Add a transaction to start tracking your portfolio.")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(height: 300)
    }
}

// MARK: - Asset Row Component

struct AssetRow: View {
    let asset: PortfolioAsset
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(asset.symbol.uppercased()) // Assuming symbol exists, or use asset.id
                    .font(.headline)
                Text("\(asset.totalQuantity.formatted()) coins")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(asset.currentValue.formatted(.currency(code: "USD")))
                    .font(.headline)
                
                Text(asset.profitLoss.formatted(.currency(code: "USD")))
                    .font(.caption)
                    .foregroundColor(asset.profitLoss >= 0 ? .green : .red)
            }
        }
        .padding()
        .contentShape(Rectangle()) // Ensures entire row is tappable
    }
}

