//
//  WeatherService.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation
import CoreLocation

protocol WeatherServiceProtocol {
    func fetchWeather(for location: CLLocationCoordinate2D) async throws -> WeatherResponse
}

extension WeatherService: WeatherServiceProtocol {}

struct WeatherService {

    private let apiKey: String
    private let baseURL: String
    private let session: URLSession

    init(apiKey: String = Config.apiKey, baseURL: String = Config.baseURL, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
    }

    func fetchWeather(for location: CLLocationCoordinate2D) async throws -> WeatherResponse {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "lat",   value: String(location.latitude)),
            URLQueryItem(name: "lon",   value: String(location.longitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(WeatherResponse.self, from: data)
    }
}
