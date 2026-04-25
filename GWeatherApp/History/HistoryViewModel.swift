//
//  HistoryViewModel.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//


import Foundation
import SwiftData
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published var records: [WeatherRecord] = []
    @Published var errorMessage: String? = nil

    private let repository: HistoryRepository

    init(modelContext: ModelContext) {
        self.repository = HistoryRepository(modelContext: modelContext)
    }

    func loadRecords() {
        do {
            records = try repository.fetchAll()
        } catch {
            errorMessage = "Failed to load history: \(error.localizedDescription)"
        }
    }

    func save(from response: WeatherResponse) {
        do {
            try repository.save(from: response)
            loadRecords()
        } catch {
            errorMessage = "Failed to save record: \(error.localizedDescription)"
        }
    }

    func delete(_ record: WeatherRecord) {
        do {
            try repository.delete(record)
            loadRecords()
        } catch {
            errorMessage = "Failed to delete record: \(error.localizedDescription)"
        }
    }

    func deleteAll() {
        do {
            try repository.deleteAll()
            loadRecords()
        } catch {
            errorMessage = "Failed to clear history: \(error.localizedDescription)"
        }
    }
}
