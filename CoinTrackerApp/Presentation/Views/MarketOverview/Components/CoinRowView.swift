//
//  CoinRowView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct CoinRowView: View {
    struct CoinModel: Identifiable, Hashable {
        let id: UUID = UUID()
        let name: String
        let symbol: String
        let iconURL: URL?
        let priceText: String
        let change24hText: String
        let isUp: Bool
        
        init(
            name: String,
            symbol: String,
            iconURL: URL?,
            priceText: String,
            change24hText: String,
            isUp: Bool
        ) {
            self.name = name
            self.symbol = symbol
            self.iconURL = iconURL
            self.priceText = priceText
            self.change24hText = change24hText
            self.isUp = isUp
        }
        
    }
    
    let coin: CoinModel
    
    var body: some View {
        HStack(spacing:12){
            AsyncImage(url: coin.iconURL){ phase in
                switch phase {
                case .empty:
                    iconPlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure(_):
                    iconPlaceholder
                @unknown default:
                    iconPlaceholder
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.priceText)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(coin.change24hText)
                    .font(.caption)
                    .foregroundColor(coin.isUp ? .green : .red)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
    
    private var iconPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.secondary.opacity(0.15))
            Image(systemName: "bitcoin.circle.fill")
                .foregroundColor(.secondary)
        }
    }
}





#Preview {
    List{
        CoinRowView(coin: .init(
            name: "Bitcoin",
            symbol: "btc",
            iconURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
            priceText: "43,210.12",
            change24hText: "+2.45%",
            isUp: true
        ))
        
        CoinRowView(coin: .init(
            name: "Ethereum",
            symbol: "eth",
            iconURL: nil,
            priceText: "$2,312.55",
            change24hText: "-1.12%",
            isUp: false
        ))
    }
    .listStyle(.plain)
}
