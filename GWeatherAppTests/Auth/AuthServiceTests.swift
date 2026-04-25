//
//  AuthServiceTests.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//
import Testing
import Foundation
@testable import GWeatherApp

@Suite("AuthService", .serialized)
struct AuthServiceTests {
    private func makeSUT() -> (sut: AuthService, suiteName: String) {
        let suiteName = UUID().uuidString
        let sut = AuthService(suiteName: suiteName)
        return (sut, suiteName)
    }

    private func cleanup(email: String, suiteName: String) {
        KeychainHelper.delete(forKey: "pw_\(email)")
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }

    @Test("register succeeds with valid email and password")
    func register_validCredentials_succeeds() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "valid@test.com", suiteName: suiteName) }

        try sut.register(email: "valid@test.com", password: "password123")

        #expect(sut.isLoggedIn == true)
    }

    @Test("register sets currentEmail after success")
    func register_success_setsCurrentEmail() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "user@test.com", suiteName: suiteName) }

        try sut.register(email: "user@test.com", password: "password123")

        #expect(sut.currentEmail == "user@test.com")
    }

    @Test("register lowercases the email before storing")
    func register_lowercasesEmail() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "upper@test.com", suiteName: suiteName) }

        try sut.register(email: "UPPER@TEST.COM", password: "password123")

        #expect(sut.currentEmail == "upper@test.com")
    }

    @Test("register trims whitespace from email")
    func register_trimsWhitespace() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "spaced@test.com", suiteName: suiteName) }

        try sut.register(email: "  spaced@test.com  ", password: "password123")

        #expect(sut.currentEmail == "spaced@test.com")
    }

    @Test("register throws emptyFields when email is blank")
    func register_emptyEmail_throwsEmptyFields() {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "", suiteName: suiteName) }

        #expect(throws: AuthError.emptyFields) {
            try sut.register(email: "", password: "password123")
        }
    }

    @Test("register throws emptyFields when password is blank")
    func register_emptyPassword_throwsEmptyFields() {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "test@test.com", suiteName: suiteName) }

        #expect(throws: AuthError.emptyFields) {
            try sut.register(email: "test@test.com", password: "")
        }
    }

    @Test("register throws invalidEmail for malformed email")
    func register_invalidEmail_throwsInvalidEmail() {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "notanemail", suiteName: suiteName) }

        #expect(throws: AuthError.invalidEmail) {
            try sut.register(email: "notanemail", password: "password123")
        }
    }

    @Test("register throws passwordTooShort for passwords under 6 characters")
    func register_shortPassword_throwsPasswordTooShort() {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "test@test.com", suiteName: suiteName) }

        #expect(throws: AuthError.passwordTooShort) {
            try sut.register(email: "test@test.com", password: "abc")
        }
    }

    @Test("register throws userAlreadyExists for duplicate email")
    func register_duplicateEmail_throwsUserAlreadyExists() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "dupe@test.com", suiteName: suiteName) }

        try sut.register(email: "dupe@test.com", password: "password123")

        #expect(throws: AuthError.userAlreadyExists) {
            try sut.register(email: "dupe@test.com", password: "password123")
        }
    }

    @Test("register with invalid email formats",
          arguments: ["plainaddress", "@missinguser.com", "missing@", "missing.domain@com"])
    func register_variousInvalidEmails_throwsInvalidEmail(email: String) {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: email, suiteName: suiteName) }

        #expect(throws: AuthError.invalidEmail) {
            try sut.register(email: email, password: "password123")
        }
    }

    @Test("login succeeds after registering with same credentials")
    func login_validCredentials_succeeds() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "login@test.com", suiteName: suiteName) }

        try sut.register(email: "login@test.com", password: "password123")
        sut.logout()
        try sut.login(email: "login@test.com", password: "password123")

        #expect(sut.isLoggedIn == true)
        #expect(sut.currentEmail == "login@test.com")
    }

    @Test("login is case-insensitive for email")
    func login_caseInsensitiveEmail_succeeds() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "case@test.com", suiteName: suiteName) }

        try sut.register(email: "case@test.com", password: "password123")
        sut.logout()
        try sut.login(email: "CASE@TEST.COM", password: "password123")

        #expect(sut.isLoggedIn == true)
    }

    @Test("login throws emptyFields when email is blank")
    func login_emptyEmail_throwsEmptyFields() {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "", suiteName: suiteName) }

        #expect(throws: AuthError.emptyFields) {
            try sut.login(email: "", password: "password123")
        }
    }

    @Test("login throws emptyFields when password is blank")
    func login_emptyPassword_throwsEmptyFields() {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "test@test.com", suiteName: suiteName) }

        #expect(throws: AuthError.emptyFields) {
            try sut.login(email: "test@test.com", password: "")
        }
    }

    @Test("login throws userNotFound for unregistered email")
    func login_unregisteredEmail_throwsUserNotFound() {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "ghost@test.com", suiteName: suiteName) }

        #expect(throws: AuthError.userNotFound) {
            try sut.login(email: "ghost@test.com", password: "password123")
        }
    }

    @Test("login throws wrongPassword for incorrect password")
    func login_wrongPassword_throwsWrongPassword() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "pw@test.com", suiteName: suiteName) }

        try sut.register(email: "pw@test.com", password: "correctpass")
        sut.logout()

        #expect(throws: AuthError.wrongPassword) {
            try sut.login(email: "pw@test.com", password: "wrongpass")
        }
    }

    @Test("logout clears isLoggedIn")
    func logout_clearsIsLoggedIn() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "out@test.com", suiteName: suiteName) }

        try sut.register(email: "out@test.com", password: "password123")
        sut.logout()

        #expect(sut.isLoggedIn == false)
        #expect(sut.currentEmail == nil)
    }

    @Test("user can log back in after logging out")
    func logout_thenLogin_succeeds() throws {
        let (sut, suiteName) = makeSUT()
        defer { cleanup(email: "relogin@test.com", suiteName: suiteName) }

        try sut.register(email: "relogin@test.com", password: "password123")
        sut.logout()
        try sut.login(email: "relogin@test.com", password: "password123")

        #expect(sut.isLoggedIn == true)
    }

    @Test("isLoggedIn is false on fresh service with no session")
    func isLoggedIn_freshService_isFalse() {
        let (sut, _) = makeSUT()
        #expect(sut.isLoggedIn == false)
    }
}
