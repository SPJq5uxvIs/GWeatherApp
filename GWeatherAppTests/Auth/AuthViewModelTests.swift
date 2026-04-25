//
//  AuthViewModelTests.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Testing
import Foundation
@testable import GWeatherApp

@Suite("AuthViewModel", .serialized)
@MainActor
struct AuthViewModelTests {
    private func makeSUT(
        registerResult: Result<Void, Error> = .success(()),
        loginResult: Result<Void, Error> = .success(()),
        isLoggedIn: Bool = false
    ) -> (sut: AuthViewModel, service: MockAuthService) {
        let service = MockAuthService()
        service.registerResult = registerResult
        service.loginResult = loginResult
        service.isLoggedIn = isLoggedIn
        let sut = AuthViewModel(service: service)
        return (sut, service)
    }

    @Test("Initial state reflects service isLoggedIn = false")
    func initialState_notLoggedIn() {
        let (sut, _) = makeSUT(isLoggedIn: false)
        #expect(sut.isLoggedIn == false)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
    }

    @Test("Initial state reflects service isLoggedIn = true (persisted session)")
    func initialState_alreadyLoggedIn() {
        let (sut, _) = makeSUT(isLoggedIn: true)
        #expect(sut.isLoggedIn == true)
    }

    @Test("register success sets isLoggedIn to true")
    func register_success_setsIsLoggedIn() {
        let (sut, _) = makeSUT()
        sut.register(email: "test@example.com", password: "password123")
        #expect(sut.isLoggedIn == true)
    }

    @Test("register success clears errorMessage")
    func register_success_clearsErrorMessage() {
        let (sut, _) = makeSUT()
        sut.errorMessage = "Previous error"
        sut.register(email: "test@example.com", password: "password123")
        #expect(sut.errorMessage == nil)
    }

    @Test("register success sets isLoading back to false")
    func register_success_clearsIsLoading() {
        let (sut, _) = makeSUT()
        sut.register(email: "test@example.com", password: "password123")
        #expect(sut.isLoading == false)
    }

    @Test("register passes correct email and password to service")
    func register_passesCorrectCredentials() {
        let (sut, service) = makeSUT()
        sut.register(email: "user@test.com", password: "secret99")
        #expect(service.lastRegisterEmail == "user@test.com")
        #expect(service.lastRegisterPassword == "secret99")
    }

    @Test("register calls service exactly once")
    func register_callsServiceOnce() {
        let (sut, service) = makeSUT()
        sut.register(email: "test@example.com", password: "password123")
        #expect(service.registerCallCount == 1)
    }

    @Test("register failure sets errorMessage")
    func register_failure_setsErrorMessage() {
        let (sut, _) = makeSUT(registerResult: .failure(AuthError.userAlreadyExists))
        sut.register(email: "test@example.com", password: "password123")
        #expect(sut.errorMessage != nil)
    }

    @Test("register failure shows userAlreadyExists message")
    func register_failure_userAlreadyExists_showsCorrectMessage() {
        let (sut, _) = makeSUT(registerResult: .failure(AuthError.userAlreadyExists))
        sut.register(email: "test@example.com", password: "password123")
        #expect(sut.errorMessage == AuthError.userAlreadyExists.errorDescription)
    }

    @Test("register failure does not set isLoggedIn")
    func register_failure_doesNotSetIsLoggedIn() {
        let (sut, _) = makeSUT(registerResult: .failure(AuthError.userAlreadyExists))
        sut.register(email: "test@example.com", password: "password123")
        #expect(sut.isLoggedIn == false)
    }

    @Test("register failure sets isLoading back to false")
    func register_failure_clearsIsLoading() {
        let (sut, _) = makeSUT(registerResult: .failure(AuthError.emptyFields))
        sut.register(email: "", password: "")
        #expect(sut.isLoading == false)
    }

    @Test("login success sets isLoggedIn to true")
    func login_success_setsIsLoggedIn() {
        let (sut, _) = makeSUT()
        sut.login(email: "test@example.com", password: "password123")
        #expect(sut.isLoggedIn == true)
    }

    @Test("login success clears errorMessage")
    func login_success_clearsErrorMessage() {
        let (sut, _) = makeSUT()
        sut.errorMessage = "Previous error"
        sut.login(email: "test@example.com", password: "password123")
        #expect(sut.errorMessage == nil)
    }

    @Test("login success sets isLoading back to false")
    func login_success_clearsIsLoading() {
        let (sut, _) = makeSUT()
        sut.login(email: "test@example.com", password: "password123")
        #expect(sut.isLoading == false)
    }

    @Test("login passes correct email and password to service")
    func login_passesCorrectCredentials() {
        let (sut, service) = makeSUT()
        sut.login(email: "user@test.com", password: "mypassword")
        #expect(service.lastLoginEmail == "user@test.com")
        #expect(service.lastLoginPassword == "mypassword")
    }

    @Test("login calls service exactly once")
    func login_callsServiceOnce() {
        let (sut, service) = makeSUT()
        sut.login(email: "test@example.com", password: "password123")
        #expect(service.loginCallCount == 1)
    }

    @Test("login failure sets errorMessage")
    func login_failure_setsErrorMessage() {
        let (sut, _) = makeSUT(loginResult: .failure(AuthError.wrongPassword))
        sut.login(email: "test@example.com", password: "wrongpass")
        #expect(sut.errorMessage != nil)
    }

    @Test("login failure shows wrongPassword message")
    func login_failure_wrongPassword_showsCorrectMessage() {
        let (sut, _) = makeSUT(loginResult: .failure(AuthError.wrongPassword))
        sut.login(email: "test@example.com", password: "wrongpass")
        #expect(sut.errorMessage == AuthError.wrongPassword.errorDescription)
    }

    @Test("login failure shows userNotFound message")
    func login_failure_userNotFound_showsCorrectMessage() {
        let (sut, _) = makeSUT(loginResult: .failure(AuthError.userNotFound))
        sut.login(email: "nobody@example.com", password: "password123")
        #expect(sut.errorMessage == AuthError.userNotFound.errorDescription)
    }

    @Test("login failure does not set isLoggedIn")
    func login_failure_doesNotSetIsLoggedIn() {
        let (sut, _) = makeSUT(loginResult: .failure(AuthError.wrongPassword))
        sut.login(email: "test@example.com", password: "wrongpass")
        #expect(sut.isLoggedIn == false)
    }

    @Test("login failure sets isLoading back to false")
    func login_failure_clearsIsLoading() {
        let (sut, _) = makeSUT(loginResult: .failure(AuthError.userNotFound))
        sut.login(email: "test@example.com", password: "password123")
        #expect(sut.isLoading == false)
    }

    // MARK: - Logout

    @Test("logout sets isLoggedIn to false")
    func logout_setsIsLoggedInToFalse() {
        let (sut, _) = makeSUT(isLoggedIn: true)
        sut.logout()
        #expect(sut.isLoggedIn == false)
    }

    @Test("logout calls service exactly once")
    func logout_callsServiceOnce() {
        let (sut, service) = makeSUT(isLoggedIn: true)
        sut.logout()
        #expect(service.logoutCallCount == 1)
    }

    @Test("logout after login clears session")
    func logout_afterLogin_clearsSession() {
        let (sut, _) = makeSUT()
        sut.login(email: "test@example.com", password: "password123")
        #expect(sut.isLoggedIn == true)
        sut.logout()
        #expect(sut.isLoggedIn == false)
    }

    @Test("currentEmail reflects service after login")
    func currentEmail_reflectsServiceAfterLogin() {
        let (sut, service) = makeSUT()
        service.currentEmail = "test@example.com"
        #expect(sut.currentEmail == "test@example.com")
    }

    @Test("currentEmail is nil when not logged in")
    func currentEmail_isNilWhenNotLoggedIn() {
        let (sut, _) = makeSUT()
        #expect(sut.currentEmail == nil)
    }
}
