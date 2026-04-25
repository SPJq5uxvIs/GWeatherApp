//
//  AuthService.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation

enum AuthError: LocalizedError {
    case userAlreadyExists
    case userNotFound
    case wrongPassword
    case emptyFields
    case passwordTooShort
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .userAlreadyExists: return "An account with this email already exists."
        case .userNotFound:      return "No account found with this email."
        case .wrongPassword:     return "Incorrect password."
        case .emptyFields:       return "Please fill in all fields."
        case .passwordTooShort:  return "Password must be at least 6 characters."
        case .invalidEmail:      return "Please enter a valid email address."
        }
    }
}

final class AuthService {
    private let defaults: UserDefaults

    init(suiteName: String? = nil) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }
    
    private enum Keys {
        static func password(for email: String) -> String { "pw_\(email)" }
        static let loggedInEmail = "loggedInEmail"
    }

    func register(email: String, password: String) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespaces)

        guard !email.isEmpty, !password.isEmpty else { throw AuthError.emptyFields }
        guard isValidEmail(email)              else { throw AuthError.invalidEmail }
        guard password.count >= 6              else { throw AuthError.passwordTooShort }
        guard KeychainHelper.read(forKey: Keys.password(for: email)) == nil
                                               else { throw AuthError.userAlreadyExists }

        let hashed = hash(password)
        _ = KeychainHelper.save(hashed, forKey: Keys.password(for: email))
        defaults.set(email, forKey: Keys.loggedInEmail)
    }

    func login(email: String, password: String) throws {
        let email = email.lowercased().trimmingCharacters(in: .whitespaces)

        guard !email.isEmpty, !password.isEmpty else { throw AuthError.emptyFields }

        guard let stored = KeychainHelper.read(forKey: Keys.password(for: email)) else {
            throw AuthError.userNotFound
        }
        guard stored == hash(password) else {
            throw AuthError.wrongPassword
        }

        defaults.set(email, forKey: Keys.loggedInEmail)
    }

    func logout() {
        defaults.removeObject(forKey: Keys.loggedInEmail)
    }

    var currentEmail: String? {
        defaults.string(forKey: Keys.loggedInEmail)
    }

    var isLoggedIn: Bool {
        currentEmail != nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    private func hash(_ input: String) -> String {
        var result: UInt64 = 5381
        for char in input.utf8 {
            result = 127 &* (result &<< 5) &+ UInt64(char)
        }
        return String(result)
    }
}
