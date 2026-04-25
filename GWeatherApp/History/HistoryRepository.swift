//
//  HistoryRepository.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//


import Foundation
import SwiftData

final class HistoryRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(from response: WeatherResponse) throws {
        let record = WeatherRecord(
            city: response.name,
            country: response.sys.country,
            temperatureCelsius: response.main.temp,
            weatherCondition: response.weather.first?.main ?? "Clear",
            sunrise: response.sys.sunrise,
            sunset: response.sys.sunset,
            dataTimestamp: response.dt
        )
        modelContext.insert(record)
        try modelContext.save()
    }

    func fetchAll() throws -> [WeatherRecord] {
        let descriptor = FetchDescriptor<WeatherRecord>(
            sortBy: [SortDescriptor(\.fetchedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func delete(_ record: WeatherRecord) throws {
        modelContext.delete(record)
        try modelContext.save()
    }

    func deleteAll() throws {
        let all = try fetchAll()
        all.forEach { modelContext.delete($0) }
        try modelContext.save()
    }
}
