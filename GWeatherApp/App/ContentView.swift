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
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            NavigationStack {
                CurrentWeatherView(viewModel: weatherVM)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign Out") {
                                authVM.logout()
                            }
                            .foregroundStyle(.red)
                        }
                    }
            }
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
    ContentView(weatherVM: WeatherViewModel(), authVM: AuthViewModel())
}
