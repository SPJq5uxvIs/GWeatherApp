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
    

    @StateObject private var authVM    = AuthViewModel()
    @StateObject private var weatherVM = WeatherViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                ContentView(weatherVM: weatherVM, authVM: authVM)
                    .modelContainer(for: WeatherRecord.self)
            } else {
                LoginView(viewModel: authVM)
            }
        }
    }
}
