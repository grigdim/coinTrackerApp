//
//  StatCardView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct StatCardViewMockModel {
    let title: String
    let value: String
}

struct StatCardView: View {
    
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(.title)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    StatCardView(title: "Hello", value: "World")
}
