//
//  HistoryRowView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//


import SwiftUI

struct HistoryRowView: View {

    let record: WeatherRecord

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: record.iconName)
                    .font(.title2)
                    .symbolRenderingMode(.multicolor)
                    .frame(width: 36)
                    .shadow(color: .black, radius: 1, x: 3, y: 3)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("\(record.city), \(record.country)")
                    .font(.headline)
                Text(record.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(record.formattedTemperature)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}
