//
//  MockWeatherService.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation
import CoreLocation
@testable import GWeatherApp

final class MockWeatherService: WeatherServiceProtocol {

    var result: Result<WeatherResponse, Error> = .failure(URLError(.unknown))
    var fetchCallCount = 0
    var lastCoordinate: CLLocationCoordinate2D?

    func fetchWeather(for location: CLLocationCoordinate2D) async throws -> WeatherResponse {
        fetchCallCount += 1
        lastCoordinate = location
        return try result.get()
    }
}
