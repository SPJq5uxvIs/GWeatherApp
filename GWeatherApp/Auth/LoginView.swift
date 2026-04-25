//
//  LoginView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import SwiftUI

struct LoginView: View {

    @ObservedObject var viewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showRegister: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 64))
                        .symbolRenderingMode(.multicolor)
                        .shadow(color: .black, radius: 1, x: 3, y: 3)
                    Text("GWeather")
                        .font(.largeTitle.weight(.bold))
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 48)

                VStack(spacing: 14) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $password)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 10)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }

                Button {
                    viewModel.login(email: email, password: password)
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Sign In")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .disabled(viewModel.isLoading)

                Spacer()

                Button {
                    viewModel.errorMessage = nil
                    showRegister = true
                } label: {
                    Text("Don't have an account? ")
                        .foregroundStyle(.secondary)
                    Text("Sign Up")
                        .foregroundStyle(Color.accentColor)
                        .bold()
                }
                .padding(.bottom, 32)
            }
            .background(LinearGradient(colors: [.white, .blue], startPoint: .bottom, endPoint: .center))
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(viewModel: viewModel)
            }
        }
    }
}
