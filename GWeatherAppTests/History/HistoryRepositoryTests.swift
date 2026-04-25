//
//  HistoryRepositoryTests.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Testing
import SwiftData
import Foundation
@testable import GWeatherApp

@Suite("HistoryRepository", .serialized)
struct HistoryRepositoryTests {

    let container: ModelContainer
    let repository: HistoryRepository

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: WeatherRecord.self, configurations: config)
        repository = HistoryRepository(modelContext: ModelContext(container))
    }

    @Test("Saving a response creates exactly one record")
    func save_createsOneRecord() throws {
        let response = WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 12345)

        try repository.save(from: response)

        let records = try repository.fetchAll()
        #expect(records.count == 1)
    }

    @Test("Saved record maps city correctly from response")
    func save_mapsCity() throws {
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))

        let record = try #require(try repository.fetchAll().first)
        #expect(record.city == "Manila")
    }

    @Test("Saved record maps temperature correctly from response")
    func save_mapsTemperature() throws {
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))

        let record = try #require(try repository.fetchAll().first)
        #expect(abs(record.temperatureCelsius - 32.0) < 0.01)
    }

    @Test("Saved record maps dataTimestamp correctly from response")
    func save_mapsDataTimestamp() throws {
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 12345))

        let record = try #require(try repository.fetchAll().first)
        #expect(record.dataTimestamp == 12345)
    }

    @Test("Saving multiple responses accumulates all records")
    func save_multipleResponses_accumulatesRecords() throws {
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Cebu",   temp: 28.0, dt: 2))
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Davao",  temp: 29.0, dt: 3))

        let records = try repository.fetchAll()
        #expect(records.count == 3)
    }

    @Test("Records are fetched with the most recently inserted record first")
    func fetchAll_returnsMostRecentlyInsertedFirst() throws {
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "First",  temp: 20, dt: 100))
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Second", temp: 30, dt: 200))

        let records = try repository.fetchAll()

        #expect(records.count == 2)
        #expect(records[0].city == "Second")
        #expect(records[1].city == "First")
    }

    @Test("Deleting a record removes it from the store")
    func delete_removesRecord() throws {
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))
        let record = try #require(try repository.fetchAll().first)

        try repository.delete(record)

        let remaining = try repository.fetchAll()
        #expect(remaining.isEmpty)
    }

    @Test("Deleting one record leaves others intact")
    func delete_leavesOtherRecordsIntact() throws {
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Cebu",   temp: 28.0, dt: 2))

        let records = try repository.fetchAll()
        try repository.delete(records[0])

        let remaining = try repository.fetchAll()
        #expect(remaining.count == 1)
        #expect(remaining.first?.city == "Manila")
    }

    @Test("deleteAll empties the store")
    func deleteAll_emptiesStore() throws {
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Manila", temp: 32.0, dt: 1))
        try repository.save(from: WeatherTestHelper.createMockResponse(city: "Cebu",   temp: 28.0, dt: 2))

        try repository.deleteAll()

        let records = try repository.fetchAll()
        #expect(records.isEmpty)
    }

    @Test("deleteAll on empty store does not throw")
    func deleteAll_onEmptyStore_doesNotThrow() throws {
        try repository.deleteAll()
        let records = try repository.fetchAll()
        #expect(records.isEmpty)
    }

    @Test("fetchAll on empty store returns empty array")
    func fetchAll_emptyStore_returnsEmptyArray() throws {
        let records = try repository.fetchAll()
        #expect(records.isEmpty)
    }
}
