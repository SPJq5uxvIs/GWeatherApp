//
//  WeatherResponseFactory.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation
@testable import GWeatherApp

enum WeatherResponseFactory {
    static func make(
        city: String = "Manila",
        country: String = "PH",
        temp: Double = 32.5,
        condition: String = "Clear",
        currentUnix: TimeInterval = 1714020000,
        sunriseUnix: TimeInterval = 1714006800,
        sunsetUnix: TimeInterval  = 1714051200
    ) -> WeatherResponse {
        WeatherResponse(
            name: city,
            sys: Sys(
                country: country,
                sunrise: sunriseUnix,
                sunset: sunsetUnix
            ),
            main: Main(
                temp: temp,
                feelsLike: temp + 3,
                humidity: 70
            ),
            weather: [
                WeatherCondition(
                    id: 800,
                    main: condition,
                    description: condition.lowercased(),
                    icon: "01d"
                )
            ],
            dt: currentUnix
        )
    }

    static func makeNight(condition: String = "Clear") -> WeatherResponse {
        make(condition: condition, currentUnix: 1714000000)
    }

    static func makePostSunset(condition: String = "Clear") -> WeatherResponse {
        make(condition: condition, currentUnix: 1714060000)
    }
}
