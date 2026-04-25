//
//  AuthServiceProtocol.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import Foundation

protocol AuthServiceProtocol {
    func register(email: String, password: String) throws
    func login(email: String, password: String) throws
    func logout()
    var currentEmail: String? { get }
    var isLoggedIn: Bool { get }
}

extension AuthService: AuthServiceProtocol {}
