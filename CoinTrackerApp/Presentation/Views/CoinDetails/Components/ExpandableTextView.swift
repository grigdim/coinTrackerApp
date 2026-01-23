//
//  ExpandableTextView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct ExpandableTextView: View {
    @State private var isExpanded: Bool = false

    let title: String
    let description: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About \(title)")
                .font(.headline)
            if let description, !description.isEmpty {
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
    }
}

#Preview {
    ExpandableTextView(
        title: "Bitcoin",
        description: """
            Bitcoin is a decentralized digital currency that operates without a central authority or intermediary. 
            It enables peer-to-peer transactions secured by cryptography and recorded on a public, immutable ledger 
            known as the blockchain.

            Created in 2009, Bitcoin introduced the concept of scarce digital money and remains the largest and most 
            widely adopted cryptocurrency by market capitalization.
            """
    )
}
