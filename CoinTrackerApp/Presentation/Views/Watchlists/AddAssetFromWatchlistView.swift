//
//  AddAssetFromWatchlistView.swift
//  CoinTrackerApp
//
//  Created by antonis.darmis on 6/2/26.
//

import SwiftUI

struct AddAssetFromWatchlistView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var viewModel: PortfolioViewModel
    
    let coin: CoinDetails
    
    // Input States
    @State private var priceString: String = ""
    @State private var quantityString: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Section 1: Coin Header
                Section {
                    HStack {
                        AsyncImage(url: coin.iconURL) { img in
                            img.resizable()
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(coin.name)
                                .font(.headline)
                            Text(coin.symbol.uppercased())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                
                // MARK: - Section 2: Inputs
                Section {
                    TextField("Buy Price ($)", text: $priceString)
                        .keyboardType(.decimalPad)
                    
                    TextField("Quantity", text: $quantityString)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Transaction Details")
                } footer: {
                    // Helper to show total cost dynamically
                    if let price = Double(priceString), let qty = Double(quantityString) {
                        Text("Total Cost: \((price * qty).formatted(.currency(code: "USD")))")
                    }
                }
            }
            .navigationTitle("Add to Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Pre-fill Price
            .onAppear {
                // Remove '$' and ',' so it becomes "95430.00" (valid for Double)
                let cleanPrice = coin.price
                    .replacingOccurrences(of: "$", with: "")
                    .replacingOccurrences(of: ",", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                priceString = cleanPrice
            }
            
            // MARK: - Toolbar Actions
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAsset()
                    }
                    .disabled(priceString.isEmpty || quantityString.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Logic
    
    private func saveAsset() {
        guard let price = Double(priceString),
              let quantity = Double(quantityString) else { return }
        
        let coinRoute = CoinDetailsRoute(
            id: coin.id,
            name: coin.name,
            iconURL: coin.iconURL
        )
        
        viewModel.addTransaction(
            coin: coinRoute,
            price: price,
            quantity: quantity
        )
        
        dismiss()
    }
}
