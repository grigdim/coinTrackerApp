//
//  CoinDetailsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct CoinDetailsRoute: Hashable {
    let id: String
    let name: String
    let iconURL: URL?
}

enum ChartRange: String, CaseIterable, Identifiable {
    case day = "24H"
    case week = "7D"
    case month = "1M"
    case year = "1Y"
    
    var id: String { self.rawValue }
}

struct CoinDetails: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String

    // Images
    let iconURL: URL?

    // Price info (already formatted for UI)
    let price: String
    let change24h: String
    let isUp: Bool

    // Market stats
    let marketCap: String
    let volume: String
    let circulatingSupply: String
    let ath: String
    let atl: String

    // Chart
    let sparkline: [Double]   // from history endpoint

    // About
    let description: String?

    // Links (UI-friendly)
    let websiteURL: URL?
    let explorerURL: URL?
    let subredditURL: URL?
}

private let mockCoin =
CoinDetails(
    id: "bitcoin",
    name: "Bitcoin",
    symbol: "BTC",
    iconURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
    price: "$42,350.12",
    change24h: "+3.42%",
    isUp: true,
    marketCap: "$830B",
    volume: "$18.4B",
    circulatingSupply: "19.6M BTC",
    ath: "$69,000",
    atl: "$67,000",
    sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9],
    description: """
    Bitcoin is a decentralized digital currency that operates without a central authority or intermediary. 
    It enables peer-to-peer transactions secured by cryptography and recorded on a public, immutable ledger 
    known as the blockchain.

    Created in 2009, Bitcoin introduced the concept of scarce digital money and remains the largest and most 
    widely adopted cryptocurrency by market capitalization.
    """,
    websiteURL: URL(string: "https://bitcoin.org"),
    explorerURL: nil,
    subredditURL: nil
)

struct CoinDetailsView: View {
    @StateObject private var viewModel: CoinDetailsViewModel
    let route: CoinDetailsRoute

    @State private var selectedChartRange: ChartRange = .day
    @State private var isFavorite: Bool = false

    
    init(route: CoinDetailsRoute) {
        let apiClient = MockApiClient()
        let repository = CoinRepositoryImpl(apiClient: apiClient)
        let useCase = GetCoinDetailUseCaseImpl(repository: repository)
        _viewModel = StateObject(
            wrappedValue: CoinDetailsViewModel(getCoinDetail: useCase)
        )
        self.route = route
    }
    
    private let coin = mockCoin
    
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    
    var body: some View {
        ScrollView {
            VStack {
                priceHeader
                
                statsGrid
                
                Picker("SelectedChartRange", selection: $selectedChartRange) {
                    ForEach(ChartRange.allCases) { chartRange in
                        Text(chartRange.rawValue).tag(chartRange)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedChartRange) { newValue in
                    viewModel.loadChart(chartRange: newValue)
                }
                
                Text("Price Chart")
                    .font(.headline)
                    .padding(.vertical, 4)
                PriceChartView()
                
                ExpandableTextView (name: coin.name, description: coin.description)

                linksSection
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    AsyncImage(url: route.iconURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .empty:
                            ProgressView()
                        default:
                            Image(systemName: "bitcoinsign.circle")
                        }
                    }
                    .frame(width: 20, height: 20)

                    Text(route.name)
                        .font(.headline)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation (.easeInOut) {
                        isFavorite.toggle()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel(isFavorite ? "Unfavorite" : "Favorite")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
        
    private var statsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            StatCardView(title: "Market Cap", value: coin.marketCap)
            StatCardView(title: "Volume", value: coin.volume)
            StatCardView(title: "ATH", value: coin.ath)
            StatCardView(title: "ATL", value: coin.atl)
        }
    }
    
    private var priceHeader: some View {
        VStack(spacing: 6) {
            Text(coin.price)
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack(spacing: 8) {
                Text(coin.symbol)
                    .foregroundColor(.secondary)

                Text(coin.change24h)
                    .foregroundColor(coin.isUp ? .green : .red)
            }
            .font(.title3)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Links")
                .font(.headline)

            if let website = coin.websiteURL {
                LinkRowView(title: "Website:", url: website)
            } else {
                LinkRowView(title: "Website:", url: nil)
            }

            LinkRowView(title:"Explorer:", url: coin.explorerURL)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        CoinDetailsView(route: .init(
            id: "bitcoin",
            name: "Bitcoin",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png")
        ))
    }
}

