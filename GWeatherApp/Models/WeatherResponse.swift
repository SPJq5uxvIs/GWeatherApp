//
//  WeatherResponse.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation

struct WeatherResponse: Codable {
    let name: String
    let sys: Sys
    let main: Main
    let weather: [WeatherCondition]
    let dt: TimeInterval
}

struct Sys: Codable {
    let country: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case humidity
    }
}

struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
