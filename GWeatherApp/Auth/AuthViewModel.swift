//
//  AuthViewModel.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol = AuthService()) {
        self.service = service
        self.isLoggedIn = service.isLoggedIn
    }

    var currentEmail: String? { service.currentEmail }

    func register(email: String, password: String) {
        errorMessage = nil
        isLoading = true
        do {
            try service.register(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func login(email: String, password: String) {
        errorMessage = nil
        isLoading = true
        do {
            try service.login(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        service.logout()
        isLoggedIn = false
    }
}
