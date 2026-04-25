//
//  HistoryDetailView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//


import SwiftUI

struct HistoryDetailView: View {

    let record: WeatherRecord

    var body: some View {
        ZStack {
            LinearGradient(colors: [.white, .blue],
                           startPoint: .bottom,
                           endPoint: .center)
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 6) {
                    Text("\(record.city), \(record.country)")
                        .font(.largeTitle.weight(.semibold))
                    Text("Fetched \(record.formattedDate)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: record.iconName)
                    .font(.system(size: 72))
                    .symbolRenderingMode(.multicolor)

                Text(record.formattedTemperature)
                    .font(.system(size: 52, weight: .thin, design: .rounded))

                HStack(spacing: 40) {
                    sunTimeItem(
                        label: "Sunrise",
                        time: formattedTime(record.sunrise),
                        icon: "sunrise.fill"
                    )
                    Divider().frame(height: 40)
                    sunTimeItem(
                        label: "Sunset",
                        time: formattedTime(record.sunset),
                        icon: "sunset.fill"
                    )
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding(24)
            .navigationTitle(record.city)
            .navigationBarTitleDisplayMode(.inline)
        }
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

    private func formattedTime(_ unix: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unix)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}
