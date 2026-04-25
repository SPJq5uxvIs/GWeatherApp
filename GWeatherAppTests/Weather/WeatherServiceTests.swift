//
//  WeatherServiceTests.swift
//  GWeatherAppTests
//
//  Created by IOS-Dev on 4/25/26.
//

import Testing
import Foundation
import CoreLocation
@testable import GWeatherApp

@Suite("WeatherService", .serialized)
struct WeatherServiceTests {
    private let manilaLocation = CLLocationCoordinate2D(
        latitude: 14.5995,
        longitude: 120.9842
    )

    private var validWeatherJSON: Data {
        """
        {
            "name": "Manila",
            "sys": {
                "country": "PH",
                "sunrise": 1714006800,
                "sunset": 1714051200
            },
            "main": {
                "temp": 32.5,
                "feels_like": 38.0,
                "humidity": 70
            },
            "weather": [
                {
                    "id": 800,
                    "main": "Clear",
                    "description": "clear sky",
                    "icon": "01d"
                }
            ],
            "dt": 1714020000
        }
        """.data(using: .utf8)!
    }

    private func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    private func makeResponse(statusCode: Int, for request: URLRequest) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    private func makeSUT() -> WeatherService {
        WeatherService(apiKey: "test-api-key", baseURL: "https://api.openweathermap.org/data/2.5/weather", session: makeMockSession())
    }
    
    @Test("Decodes a valid 200 response into WeatherResponse")
    func fetchWeather_success_returnsDecodedResponse() async throws {
        MockURLProtocol.requestHandler = { request in
            (makeResponse(statusCode: 200, for: request), validWeatherJSON)
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        let result = try await makeSUT().fetchWeather(for: manilaLocation)

        #expect(result.name == "Manila")
        await #expect(result.sys.country == "PH")
        await #expect(abs(result.main.temp - 32.5) < 0.01)
        await #expect(result.weather.first?.main == "Clear")
    }

    @Test("Empty weather array still decodes without crashing")
    func fetchWeather_emptyWeatherArray_stillDecodes() async throws {
        let json = """
        {
            "name": "Manila",
            "sys": { "country": "PH", "sunrise": 1714006800, "sunset": 1714051200 },
            "main": { "temp": 30.0, "feels_like": 35.0, "humidity": 65 },
            "weather": [],
            "dt": 1714020000
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            (makeResponse(statusCode: 200, for: request), json)
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        let result = try await makeSUT().fetchWeather(for: manilaLocation)

        #expect(result.name == "Manila")
        #expect(result.weather.isEmpty)
    }

    @Test("Builds URL with correct lat, lon, units and apiKey query params")
    func fetchWeather_buildsCorrectQueryParams() async throws {
        var capturedRequest: URLRequest?

        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (makeResponse(statusCode: 200, for: request), validWeatherJSON)
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        _ = try await makeSUT().fetchWeather(for: manilaLocation)

        let url = try #require(capturedRequest?.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = try #require(components.queryItems)
        let query = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })

        #expect(query["lat"]   == "14.5995")
        #expect(query["lon"]   == "120.9842")
        #expect(query["units"] == "metric")
        #expect(query["appid"] == "test-api-key")
    }

    @Test("Uses GET HTTP method")
    func fetchWeather_usesGETMethod() async throws {
        var capturedRequest: URLRequest?

        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (makeResponse(statusCode: 200, for: request), validWeatherJSON)
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        _ = try await makeSUT().fetchWeather(for: manilaLocation)

        #expect((capturedRequest?.httpMethod ?? "GET") == "GET")
    }

    @Test("Throws badServerResponse for non-200 status codes",
          arguments: [400, 401, 403, 404, 500])
    func fetchWeather_nonSuccess_throwsBadServerResponse(statusCode: Int) async throws {
        MockURLProtocol.requestHandler = { request in
            (makeResponse(statusCode: statusCode, for: request), Data())
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        await #expect(throws: URLError.self) {
            _ = try await makeSUT().fetchWeather(for: manilaLocation)
        }
    }
    
    @Test("Throws DecodingError for malformed JSON")
    func fetchWeather_malformedJSON_throwsDecodingError() async throws {
        let badJSON = "{ not valid json }".data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            (makeResponse(statusCode: 200, for: request), badJSON)
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        await #expect(throws: DecodingError.self) {
            _ = try await makeSUT().fetchWeather(for: manilaLocation)
        }
    }

    @Test("Throws DecodingError for empty response body")
    func fetchWeather_emptyBody_throwsDecodingError() async throws {
        MockURLProtocol.requestHandler = { request in
            (makeResponse(statusCode: 200, for: request), Data())
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        await #expect(throws: DecodingError.self) {
            _ = try await makeSUT().fetchWeather(for: manilaLocation)
        }
    }

    @Test("Throws DecodingError when required fields are missing")
    func fetchWeather_missingRequiredFields_throwsDecodingError() async throws {
        let incomplete = """
        { "name": "Manila" }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            (makeResponse(statusCode: 200, for: request), incomplete)
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        await #expect(throws: DecodingError.self) {
            _ = try await makeSUT().fetchWeather(for: manilaLocation)
        }
    }

    @Test("Propagates URLError when device is offline")
    func fetchWeather_offline_throwsNotConnectedToInternet() async throws {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        await #expect(throws: URLError.self) {
            _ = try await makeSUT().fetchWeather(for: manilaLocation)
        }
    }

    @Test("Propagates URLError on request timeout")
    func fetchWeather_timeout_throwsTimedOut() async throws {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }
        
        defer { MockURLProtocol.requestHandler = nil }

        await #expect(throws: URLError.self) {
            _ = try await makeSUT().fetchWeather(for: manilaLocation)
        }
    }
}
