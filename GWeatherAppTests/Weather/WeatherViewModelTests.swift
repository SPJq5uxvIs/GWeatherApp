//
//  WeatherViewModelTests.swift
//  GWeatherAppTests
//
//  Created by IOS-Dev on 4/25/26.
//

import Testing
import Foundation
import CoreLocation
@testable import GWeatherApp

@Suite("WeatherViewModel", .serialized)
@MainActor
struct WeatherViewModelTests {
    private func makeSUT(result: Result<WeatherResponse, Error> = .success(WeatherResponseFactory.make())) -> (sut: WeatherViewModel, service: MockWeatherService) {
        let service = MockWeatherService()
        service.result = result
        let sut = WeatherViewModel(service: service)
        defer { MockURLProtocol.requestHandler = nil }
        return (sut, service)
    }

    private let testCoordinate = CLLocationCoordinate2D(
        latitude: 14.5995,
        longitude: 120.9842
    )

    @Test("Initial state shows placeholder values")
    func initialState_showsPlaceholders() {
        let (sut, _) = makeSUT()

        #expect(sut.cityName == "--")
        #expect(sut.country == "--")
        #expect(sut.temperatureCelsius == "--")
        #expect(sut.sunrise == "--")
        #expect(sut.sunset == "--")
        #expect(sut.weatherIconName == "cloud.fill")
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
        #expect(sut.lastResponse == nil)
    }

    @Test("loadWeather clears isLoading after completing")
    func loadWeather_setsAndClearsIsLoading() async {
        let (sut, _) = makeSUT()

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.isLoading == false)
    }

    @Test("loadWeather success populates city and country")
    func loadWeather_success_populatesCityAndCountry() async {
        let response = WeatherResponseFactory.make(city: "Manila", country: "PH")
        let (sut, _) = makeSUT(result: .success(response))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.cityName == "Manila")
        #expect(sut.country == "PH")
    }

    @Test("loadWeather success formats temperature correctly")
    func loadWeather_success_formatsTemperature() async {
        let response = WeatherResponseFactory.make(temp: 32.5)
        let (sut, _) = makeSUT(result: .success(response))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.temperatureCelsius == "32.5°C")
    }

    @Test("loadWeather success rounds temperature to 1 decimal")
    func loadWeather_success_roundsTemperatureToOneDecimal() async {
        let response = WeatherResponseFactory.make(temp: 28.0)
        let (sut, _) = makeSUT(result: .success(response))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.temperatureCelsius == "28.0°C")
    }

    @Test("loadWeather success sets lastResponse")
    func loadWeather_success_setsLastResponse() async {
        let response = WeatherResponseFactory.make(city: "Manila")
        let (sut, _) = makeSUT(result: .success(response))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.lastResponse != nil)
        #expect(sut.lastResponse?.name == "Manila")
    }

    @Test("loadWeather success clears any previous errorMessage")
    func loadWeather_success_clearsErrorMessage() async {
        let (sut, _) = makeSUT()
        sut.errorMessage = "Previous error"

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.errorMessage == nil)
    }

    @Test("loadWeather calls service with the provided coordinate")
    func loadWeather_callsServiceWithCorrectCoordinate() async {
        let (sut, service) = makeSUT()

        await sut.loadWeather(for: testCoordinate)

        #expect(service.fetchCallCount == 1)
        #expect(abs((service.lastCoordinate?.latitude  ?? 0) - testCoordinate.latitude)  < 0.0001)
        #expect(abs((service.lastCoordinate?.longitude ?? 0) - testCoordinate.longitude) < 0.0001)
    }

    @Test("loadWeather failure sets errorMessage")
    func loadWeather_failure_setsErrorMessage() async {
        let (sut, _) = makeSUT(result: .failure(URLError(.notConnectedToInternet)))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.errorMessage != nil)
    }

    @Test("loadWeather failure leaves city as placeholder")
    func loadWeather_failure_leavesCityAsPlaceholder() async {
        let (sut, _) = makeSUT(result: .failure(URLError(.timedOut)))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.cityName == "--")
    }

    @Test("loadWeather failure sets isLoading to false")
    func loadWeather_failure_clearsIsLoading() async {
        let (sut, _) = makeSUT(result: .failure(URLError(.badServerResponse)))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.isLoading == false)
    }

    @Test("loadWeather failure does not set lastResponse")
    func loadWeather_failure_doesNotSetLastResponse() async {
        let (sut, _) = makeSUT(result: .failure(URLError(.unknown)))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.lastResponse == nil)
    }

    @Test("Daytime Clear shows sun icon")
    func resolveIcon_daytime_clear_returnsSun() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Clear",
            currentUnix: 1714020000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "sun.max.fill")
    }

    @Test("Daytime Clouds shows cloud-sun icon")
    func resolveIcon_daytime_clouds_returnsCloudSun() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Clouds",
            currentUnix: 1714020000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "cloud.sun.fill")
    }

    @Test("Nighttime Clear shows moon-stars icon")
    func resolveIcon_night_clear_returnsMoonStars() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Clear",
            currentUnix: 1714000000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "moon.stars.fill")
    }

    @Test("Post-sunset Clear shows moon-stars icon")
    func resolveIcon_postSunset_clear_returnsMoonStars() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Clear",
            currentUnix: 1714060000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "moon.stars.fill")
    }

    @Test("Nighttime Clouds shows cloud-moon icon")
    func resolveIcon_night_clouds_returnsCloudMoon() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Clouds",
            currentUnix: 1714000000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "cloud.moon.fill")
    }

    @Test("Rain and Drizzle always show rain icon",
          arguments: ["Rain", "Drizzle"])
    func resolveIcon_rainConditions_returnsRainIcon(condition: String) {
        let (sut, _) = makeSUT()

        let dayIcon = sut.resolveIcon(
            condition: condition,
            currentUnix: 1714020000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        let nightIcon = sut.resolveIcon(
            condition: condition,
            currentUnix: 1714000000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )

        #expect(dayIcon   == "cloud.rain.fill")
        #expect(nightIcon == "cloud.rain.fill")
    }

    @Test("Thunderstorm always shows bolt-rain icon")
    func resolveIcon_thunderstorm_returnsBoltRain() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Thunderstorm",
            currentUnix: 1714020000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "cloud.bolt.rain.fill")
    }

    @Test("Snow always shows snowflake icon")
    func resolveIcon_snow_returnsSnowflake() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Snow",
            currentUnix: 1714020000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "snowflake")
    }

    @Test("Mist, Fog, Haze always show fog icon",
          arguments: ["Mist", "Fog", "Haze"])
    func resolveIcon_fogConditions_returnsFogIcon(condition: String) {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: condition,
            currentUnix: 1714020000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "cloud.fog.fill")
    }

    @Test("Unknown condition defaults to sun during day")
    func resolveIcon_unknown_daytime_returnsSun() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Tornado",
            currentUnix: 1714020000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "sun.max.fill")
    }

    @Test("Unknown condition defaults to moon at night")
    func resolveIcon_unknown_night_returnsMoon() {
        let (sut, _) = makeSUT()
        let icon = sut.resolveIcon(
            condition: "Tornado",
            currentUnix: 1714000000,
            sunriseUnix: 1714006800,
            sunsetUnix:  1714051200
        )
        #expect(icon == "moon.fill")
    }

    @Test("loadWeather applies correct daytime icon from response")
    func loadWeather_appliesDaytimeIcon() async {
        let response = WeatherResponseFactory.make(condition: "Clear")
        let (sut, _) = makeSUT(result: .success(response))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.weatherIconName == "sun.max.fill")
    }

    @Test("loadWeather applies moon icon for nighttime Clear response")
    func loadWeather_appliesNightIcon() async {
        let response = WeatherResponseFactory.makeNight(condition: "Clear")
        let (sut, _) = makeSUT(result: .success(response))

        await sut.loadWeather(for: testCoordinate)

        #expect(sut.weatherIconName == "moon.stars.fill")
    }
}
