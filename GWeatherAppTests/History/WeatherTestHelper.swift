//
//  WeatherTestHelper.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//


// WeatherTestHelper.swift
import Foundation
@testable import GWeatherApp

enum WeatherTestHelper {
    static func createMockResponse(city: String, temp: Double, dt: TimeInterval) -> WeatherResponse {
        WeatherResponse(
            name: city,
            sys: Sys(country: "PH", sunrise: 1000, sunset: 2000),
            main: Main(temp: temp, feelsLike: temp + 2, humidity: 70),
            weather: [WeatherCondition(id: 800, main: "Clear", description: "clear", icon: "01d")],
            dt: dt
        )
    }
}