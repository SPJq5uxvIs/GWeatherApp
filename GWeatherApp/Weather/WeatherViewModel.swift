//
//  WeatherViewModel.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class WeatherViewModel: NSObject, ObservableObject {

    @Published var cityName: String = "--"
    @Published var country: String = "--"
    @Published var temperatureCelsius: String = "--"
    @Published var sunrise: String = "--"
    @Published var sunset: String = "--"
    @Published var weatherIconName: String = "cloud.fill"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var lastResponse: WeatherResponse? = nil

    private let service: WeatherServiceProtocol
    private let locationManager: CLLocationManager
    private var currentLocation: CLLocationCoordinate2D?

    init(service: WeatherServiceProtocol = WeatherService(), locationManager: CLLocationManager = CLLocationManager()) {
        self.service = service
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestWeather() {
        errorMessage = nil
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied. Enable it in Settings."
        @unknown default:
            break
        }
    }

    func loadWeather(for coordinate: CLLocationCoordinate2D) async {
        isLoading = true
        do {
            let weather = try await service.fetchWeather(for: coordinate)
            applyWeather(weather)
        } catch {
            errorMessage = "Failed to load weather: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func applyWeather(_ weather: WeatherResponse) {
        lastResponse = weather
        cityName = weather.name
        country = weather.sys.country
        temperatureCelsius = String(format: "%.1f°C", weather.main.temp)
        sunrise = formattedTime(weather.sys.sunrise)
        sunset  = formattedTime(weather.sys.sunset)
        weatherIconName = resolveIcon(condition: weather.weather.first?.main ?? "Clear", currentUnix: weather.dt, sunriseUnix: weather.sys.sunrise, sunsetUnix: weather.sys.sunset)
        errorMessage = nil
    }

    func resolveIcon(condition: String, currentUnix: TimeInterval, sunriseUnix: TimeInterval, sunsetUnix: TimeInterval) -> String {
        let isNight = currentUnix < sunriseUnix || currentUnix > sunsetUnix
        switch condition {
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
        case "Mist", "Fog", "Haze":
            return "cloud.fog.fill"
        default:             
            return isNight ? "moon.fill" : "sun.max.fill"
        }
    }

    private func formattedTime(_ unix: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unix)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            self.currentLocation = location.coordinate
            await self.loadWeather(for: location.coordinate)
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = "Location error: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
