//
//  RegisterView.swift
//  GWeatherApp
//
//  Created by IOS-Dev on 4/25/26.
//

import SwiftUI

struct RegisterView: View {

    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var localError: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.accentColor)
                Text("Create Account")
                    .font(.largeTitle.weight(.bold))
                Text("Start tracking your weather")
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

                SecureField("Password (min. 6 characters)", text: $password)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)

            // Error (local validation or service error)
            if let error = localError ?? viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, 10)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            }

            Button {
                attemptRegister()
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Create Account")
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
                dismiss()
            } label: {
                Text("Already have an account? ")
                    .foregroundStyle(.secondary)
                Text("Sign In")
                    .foregroundStyle(Color.accentColor)
                    .bold()
            }
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func attemptRegister() {
        localError = nil
        viewModel.errorMessage = nil

        guard password == confirmPassword else {
            localError = "Passwords do not match."
            return
        }
        viewModel.register(email: email, password: password)
    }
}
