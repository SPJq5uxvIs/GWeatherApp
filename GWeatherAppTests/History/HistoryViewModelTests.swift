//
//  HistoryViewModelTests.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Testing
import SwiftData
import Foundation
@testable import GWeatherApp

@Suite("HistoryViewModel", .serialized)
@MainActor
struct HistoryViewModelTests {
    let viewModel: HistoryViewModel
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WeatherRecord.self, configurations: config)
        self.context = ModelContext(container)
        self.viewModel = HistoryViewModel(modelContext: context)
    }

    @Test("Initial records array is empty")
    func initialState_recordsIsEmpty() {
        #expect(viewModel.records.isEmpty)
    }

    @Test("Initial errorMessage is nil")
    func initialState_errorMessageIsNil() {
        #expect(viewModel.errorMessage == nil)
    }

    @Test("save publishes the new record immediately")
    func save_publishesRecord() {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Cebu", temp: 28.0, dt: 555))

        #expect(viewModel.records.count == 1)
        #expect(viewModel.records.first?.city == "Cebu")
    }

    @Test("save multiple times accumulates all records in published array")
    func save_multiple_accumulatesRecords() {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Cebu",   temp: 28.0, dt: 2))
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Davao",  temp: 29.0, dt: 3))

        #expect(viewModel.records.count == 3)
    }

    @Test("save does not set errorMessage on success")
    func save_success_doesNotSetErrorMessage() {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))

        #expect(viewModel.errorMessage == nil)
    }

    @Test("loadRecords after save reflects persisted data")
    func loadRecords_reflectsPersistedData() {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Cebu", temp: 28.0, dt: 555))

        viewModel.loadRecords()

        #expect(viewModel.records.count == 1)
        #expect(viewModel.records.first?.city == "Cebu")
    }

    @Test("delete removes the record from published array")
    func delete_removesRecord() throws {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Davao", temp: 29.0, dt: 999))
        let recordToDelete = try #require(viewModel.records.first)

        viewModel.delete(recordToDelete)

        #expect(viewModel.records.isEmpty)
    }

    @Test("delete only removes the targeted record")
    func delete_onlyRemovesTargetedRecord() throws {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Cebu",   temp: 28.0, dt: 2))

        let recordToDelete = try #require(viewModel.records.first)
        viewModel.delete(recordToDelete)

        #expect(viewModel.records.count == 1)
        #expect(viewModel.records.first?.city == "Manila")
    }

    @Test("delete does not set errorMessage on success")
    func delete_success_doesNotSetErrorMessage() throws {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))
        let record = try #require(viewModel.records.first)

        viewModel.delete(record)

        #expect(viewModel.errorMessage == nil)
    }

    @Test("deleteAll clears the published records array")
    func deleteAll_clearsRecords() {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Cebu",   temp: 28.0, dt: 2))

        viewModel.deleteAll()

        #expect(viewModel.records.isEmpty)
    }

    @Test("deleteAll does not set errorMessage on success")
    func deleteAll_success_doesNotSetErrorMessage() {
        viewModel.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))

        viewModel.deleteAll()

        #expect(viewModel.errorMessage == nil)
    }

    @Test("deleteAll on empty store does not crash or set errorMessage")
    func deleteAll_onEmptyStore_doesNotCrash() {
        viewModel.deleteAll()

        #expect(viewModel.records.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }
}
