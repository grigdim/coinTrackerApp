//
//  TransactionHistoryView.swift
//  CoinTrackerApp
//
//  Created by antonis.darmis on 30/1/26.
//

import SwiftUI

struct TransactionHistoryView: View {
    let asset: PortfolioAsset
    var body: some View {
        List(asset.transactions) { tx in
            HStack {
                VStack(alignment: .leading) {
                    Text("Buy").font(.headline).foregroundColor(.green)
                    Text(tx.date.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(tx.quantity.formatted()) @ \(tx.pricePerCoin.formatted())").font(.subheadline)
                    Text(tx.totalCost.formatted(.currency(code: "USD")))
                }
            }
        }
        .navigationTitle("\(asset.symbol) History")
    }
}
