//
//  CurrentWeatherView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import SwiftUI

struct CurrentWeatherView: View {
    var body: some View {
        VStack(spacing: 24) {
            locationHeader
            temperatureBlock
            sunTimesRow
        }
        .padding(24)
    }
    
    private var locationHeader: some View {
        VStack(spacing: 4) {
            Text("City")
                .font(.largeTitle.weight(.semibold))
            Text("Country")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var temperatureBlock: some View {
        VStack(spacing: 12) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 72))
                .symbolRenderingMode(.multicolor)
            Text("67 Degrees")
                .font(.system(size: 52, weight: .thin, design: .rounded))
        }
    }

    private var sunTimesRow: some View {
        HStack(spacing: 40) {
            sunTimeItem(label: "Sunrise", time: "6:00 AM",
                        icon: "sunrise.fill")
            Divider().frame(height: 40)
            sunTimeItem(label: "Sunset",  time: "7:00 PM",
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
}

#Preview {
    CurrentWeatherView()
}
