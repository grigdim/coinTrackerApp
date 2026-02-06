//
//  AddHoldingView.swift
//  CoinTrackerApp
//
//  Created by antonis.darmis on 30/1/26.
//

import SwiftUI

struct AddHoldingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: PortfolioViewModel
    let coin: CoinDetailsRoute
    
    @State private var priceString = ""
    @State private var quantityString = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Coin Name")
                        Spacer()
                        Text(coin.name).foregroundColor(.secondary)
                    }
                }
                
                Section {
                    TextField("Buy Price ($)", text: $priceString)
                        .keyboardType(.decimalPad)
                    
                    TextField("Quantity", text: $quantityString)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Transaction Details")
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let price = Double(priceString), let qty = Double(quantityString) {
                            viewModel.addTransaction(coin: coin, price: price, quantity: qty)
                            dismiss()
                        }
                    }
                    .disabled(priceString.isEmpty || quantityString.isEmpty)
                }
            }
        }
    }
}
