//
//  ContentView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var weatherVM: WeatherViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            CurrentWeatherView(viewModel: weatherVM)
                .tabItem {
                    Label("Now", systemImage: "cloud.sun.fill")
                }
            
            HistoryListView(viewModel: HistoryViewModel(modelContext: modelContext))
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
        .onReceive(weatherVM.$lastResponse.compactMap { $0 }) { response in
            let repo = HistoryRepository(modelContext: modelContext)
            withAnimation {
                try? repo.save(from: response)
            }
        }
    }
}

#Preview {
    ContentView(weatherVM: WeatherViewModel())
}
