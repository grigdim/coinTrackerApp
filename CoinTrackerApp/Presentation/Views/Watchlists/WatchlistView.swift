//
//  WatchlistsView.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

   
import SwiftUI

struct WatchlistView: View {
    @StateObject private var viewModel = WatchlistsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.watchlists) { watchlist in
                    NavigationLink(destination: WatchlistDetailView(watchlist: watchlist)) {
                        HStack {
                            Image(systemName: watchlist.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading) {
                                Text(watchlist.name)
                                    .font(.headline)
                                Text("\(watchlist.coins.count) coins")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let index = viewModel.watchlists.firstIndex(of: watchlist) {
                                viewModel.deleteWatchlist(at: IndexSet(integer: index))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: viewModel.moveWatchlist)  
                .onDelete(perform: viewModel.deleteWatchlist)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("My Watchlists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Add new watchlist logic
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    WatchlistView()
}
