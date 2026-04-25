//
//  HistoryListView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import SwiftUI
import SwiftData

struct HistoryListView: View {

    @ObservedObject var viewModel: HistoryViewModel
    @State private var showingClearConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.records.isEmpty {
                    emptyState
                } else {
                    recordsList
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !viewModel.records.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear All", role: .destructive) {
                            showingClearConfirm = true
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .confirmationDialog(
                "Clear all history?",
                isPresented: $showingClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    withAnimation {
                        viewModel.deleteAll()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear() {
            withAnimation {
                viewModel.loadRecords()
            }
        }
    }

    private var recordsList: some View {
        List {
            ForEach(viewModel.records) { record in
                NavigationLink(destination: HistoryDetailView(record: record)) {
                    HistoryRowView(record: record)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { viewModel.delete(viewModel.records[$0]) }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No history yet")
                .font(.headline)
            Text("Weather data will appear here\neach time you open the app.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
