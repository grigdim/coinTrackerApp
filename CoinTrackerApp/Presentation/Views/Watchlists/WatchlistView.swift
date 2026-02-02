//
//  WatchlistsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

struct WatchlistView: View {
    @StateObject private var viewModel = WatchlistsViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach($viewModel.watchlists) { $watchlist in
                    ZStack {
                        NavigationLink(
                            destination: WatchlistDetailView(
                                watchlist: $watchlist
                            )
                        ) {
                            EmptyView()
                        }
                        .opacity(0)
                        // Visual Row Content
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Image(systemName: watchlist.icon)
                                    .foregroundColor(.blue)
                            }

                            VStack(alignment: .leading) {
                                Text(watchlist.name)
                                    .font(.headline)
                                Text("\(watchlist.coins.count) coins")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }

                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let index = viewModel.watchlists.firstIndex(
                                where: { $0.id == watchlist.id })
                            {
                                viewModel.deleteWatchlist(
                                    at: IndexSet(integer: index)
                                )
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteWatchlist)
                .onMove(perform: viewModel.moveWatchlist)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Watchlists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

#Preview {
    WatchlistView()
}
