//
//  PriceChartView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct PriceChartView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Text("Mock Price Chart")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    PriceChartView()
}
