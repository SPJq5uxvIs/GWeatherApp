//
//  MockAuthService.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation
@testable import GWeatherApp

final class MockAuthService: AuthServiceProtocol {

    var registerResult: Result<Void, Error> = .success(())
    var loginResult: Result<Void, Error> = .success(())

    var registerCallCount = 0
    var loginCallCount = 0
    var logoutCallCount = 0
    var lastRegisterEmail: String?
    var lastRegisterPassword: String?
    var lastLoginEmail: String?
    var lastLoginPassword: String?

    var currentEmail: String? = nil
    var isLoggedIn: Bool = false

    func register(email: String, password: String) throws {
        registerCallCount += 1
        lastRegisterEmail = email
        lastRegisterPassword = password
        try registerResult.get()
        currentEmail = email
        isLoggedIn = true
    }

    func login(email: String, password: String) throws {
        loginCallCount += 1
        lastLoginEmail = email
        lastLoginPassword = password
        try loginResult.get()
        currentEmail = email
        isLoggedIn = true
    }

    func logout() {
        logoutCallCount += 1
        currentEmail = nil
        isLoggedIn = false
    }
}
