//
//  GWeatherAppApp.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import SwiftUI
import SwiftData

@main
struct GWeatherAppApp: App {
    
    @StateObject var weatherVM = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(weatherVM: weatherVM)
                .modelContainer(for: WeatherRecord.self)
        }
    }
}
