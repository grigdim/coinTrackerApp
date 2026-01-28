//
//  WatchlistAddView.swift
//  CoinTrackerApp
//
//  Created by antonis.darmis on 28/1/26.
//
//

import SwiftUI

struct AddWatchlistView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WatchlistsViewModel
    
    @State private var name = ""
    @State private var selectedIcon = "star.fill"
    
    let icons = ["star.fill", "flame.fill", "bolt.fill", "heart.fill", "tag.fill", "bookmark.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("List Details") {
                    TextField("Watchlist Name", text: $name)
                    
                    Picker("Icon", selection: $selectedIcon) {
                        ForEach(icons, id: \.self) { icon in
                            Label(icon, systemImage: icon)
                                .labelStyle(.iconOnly)
                                .tag(icon)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        viewModel.addWatchlist(name: name, icon: selectedIcon)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AddWatchlistView(viewModel: WatchlistsViewModel())
}
