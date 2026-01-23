//
//  CoinRowView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct CoinRowView: View {

    let coin: MarketRow

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: coin.iconURL) { phase in
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
                Text(coin.price)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if !coin.sparkline.isEmpty {
                        SparklineView(values: coin.sparkline)
                            .frame(width: 32, height: 32)
                    }

                    Text(coin.change24h)
                        .font(.caption)
                        .foregroundColor(coin.isUp ? .green : .red)
                        .lineLimit(1)
                }
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
    List {
        CoinRowView(
            coin: .init(
                id: "btc",
                name: "Bitcoin",
                symbol: "btc",
                iconURL: URL(
                    string:
                        "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
                ),
                price: "43,210.12",
                marketCap: "$850B",
                volume: "$25B",
                circulatingSupply: "19.3M BTC",
                ath: "$69,000",
                atl: "$65",
                change24h: "+2.45%",
                change24hRaw: 2.45,
                isUp: true,
                sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9]
            )
        )

        CoinRowView(
            coin: .init(
                id: "eth",
                name: "Ethereum",
                symbol: "eth",
                iconURL: nil,
                price: "$2,312.55",
                marketCap: "$280B",
                volume: "$12B",
                circulatingSupply: "120.3M ETH",
                ath: "$4,878",
                atl: "$0.43",
                change24h: "-1.12%",
                change24hRaw: -1.12,
                isUp: false,
                sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9]
            )
        )
    }
    .listStyle(.plain)
}
