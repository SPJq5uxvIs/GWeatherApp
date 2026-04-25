//
//  WeatherRecord.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation
import SwiftData

@Model
final class WeatherRecord {
    var city: String
    var country: String
    var temperatureCelsius: Double
    var weatherCondition: String
    var sunrise: TimeInterval
    var sunset: TimeInterval
    var fetchedAt: Date
    var dataTimestamp: TimeInterval
    @Attribute(.unique) var recordId: String

    init(
        city: String,
        country: String,
        temperatureCelsius: Double,
        weatherCondition: String,
        sunrise: TimeInterval,
        sunset: TimeInterval,
        fetchedAt: Date = .now,
        dataTimestamp: TimeInterval
    ) {
        self.city = city
        self.country = country
        self.temperatureCelsius = temperatureCelsius
        self.weatherCondition = weatherCondition
        self.sunrise = sunrise
        self.sunset = sunset
        self.fetchedAt = fetchedAt
        self.dataTimestamp = dataTimestamp
        self.recordId = "\(city)-\(dataTimestamp)"
    }

    var formattedTemperature: String {
        String(format: "%.1f°C", temperatureCelsius)
    }

    var formattedDate: String {
        fetchedAt.formatted(date: .abbreviated, time: .shortened)
    }

    var iconName: String {
        let isNight = {
            let t = fetchedAt.timeIntervalSince1970
            return t < sunrise || t > sunset
        }()

        switch weatherCondition {
        case "Clear":
            return isNight ? "moon.stars.fill" : "sun.max.fill"
        case "Clouds":      
            return isNight ? "cloud.moon.fill" : "cloud.sun.fill"
        case "Rain",
             "Drizzle":     
            return "cloud.rain.fill"
        case "Thunderstorm":
            return "cloud.bolt.rain.fill"
        case "Snow":        
            return "snowflake"
        case "Mist",
             "Fog",
             "Haze":
            return "cloud.fog.fill"
        default:            
            return isNight ? "moon.fill" : "sun.max.fill"
        }
    }
}
