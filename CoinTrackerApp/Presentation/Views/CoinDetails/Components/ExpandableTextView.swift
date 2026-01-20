//
//  ExpandableTextView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct ExpandableTextView: View {
    let coin: CoinDetails
    @State private var isExpanded: Bool = false
    
    var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("About \(coin.name)")
                    .font(.headline)
                if let description = coin.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {

                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(isExpanded ? nil : 3)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(.easeInOut, value: isExpanded)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    isExpanded.toggle()
                                }
                            }

                        Button {
                            withAnimation(.easeInOut) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Text(isExpanded ? "Read less" : "Read more")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }

            }
            .padding()
    }
}

#Preview {
    ExpandableTextView(coin: .init(
        id: "bitcoin",
        name: "Bitcoin",
        symbol: "BTC",
        iconURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
        price: "$42,350.12",
        marketCap: "$830B",
        volume: "$18.4B",
        circulatingSupply: "19.6M BTC",
        ath: "$69,000",
        atl: "$67,000",
        change24h: "+3.42%",
        isUp: true,
        sparkline: [1.0, 2.5, 3.14, 4.0, 5.6, 6.7, 7.8, 8.9],
        description: """
        Bitcoin is a decentralized digital currency that operates without a central authority or intermediary. 
        It enables peer-to-peer transactions secured by cryptography and recorded on a public, immutable ledger 
        known as the blockchain.

        Created in 2009, Bitcoin introduced the concept of scarce digital money and remains the largest and most 
        widely adopted cryptocurrency by market capitalization.
        """,
        externalLink: URL(string: "https://bitcoin.org")
    ))
}
