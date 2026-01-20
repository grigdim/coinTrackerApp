//
//  LinkRowView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct LinkRowView: View {
    let coin: CoinDetails
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    LinkRowView(coin: .init(
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
