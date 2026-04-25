//
//  ContentView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CurrentWeatherView(viewModel: WeatherViewModel())
                .tabItem {
                    Label("Now", systemImage: "cloud.sun.fill")
                }
            
            HistoryListView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}

#Preview {
    ContentView()
}
