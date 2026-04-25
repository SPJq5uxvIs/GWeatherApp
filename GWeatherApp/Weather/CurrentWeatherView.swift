//
//  CurrentWeatherView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import SwiftUI

struct CurrentWeatherView: View {

    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        ZStack {
            
            LinearGradient(colors: [.white, .blue],
                           startPoint: .bottom,
                           endPoint: .center)
            
            if viewModel.isLoading {
                ProgressView("Fetching weather…")
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else {
                weatherContent
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.requestWeather()
        }
    }

    private var weatherContent: some View {
        VStack(spacing: 24) {
            locationHeader
            temperatureBlock
            sunTimesRow
        }
        .padding(24)
    }

    private var locationHeader: some View {
        VStack(spacing: 4) {
            Text(viewModel.cityName)
                .font(.largeTitle.weight(.semibold))
            Text(viewModel.country)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var temperatureBlock: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.weatherIconName)
                .font(.system(size: 72))
                .symbolRenderingMode(.multicolor)
            Text(viewModel.temperatureCelsius)
                .font(.system(size: 52, weight: .thin, design: .rounded))
        }
    }

    private var sunTimesRow: some View {
        HStack(spacing: 40) {
            sunTimeItem(label: "Sunrise", time: viewModel.sunrise,
                        icon: "sunrise.fill")
            Divider().frame(height: 40)
            sunTimeItem(label: "Sunset",  time: viewModel.sunset,
                        icon: "sunset.fill")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func sunTimeItem(label: String, time: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .symbolRenderingMode(.multicolor)
            Text(time)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Retry") { viewModel.requestWeather() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    CurrentWeatherView(viewModel: WeatherViewModel())
}
