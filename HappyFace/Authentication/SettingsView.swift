//
//  SettingsView.swift
//  HappyFace
//
//  Created by Piotr Woźniak on 07/08/2023.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var triggerEmailUpdate = false
    
    @Published var newEmail = ""
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = user.email else { throw URLError(.fileDoesNotExist) }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        guard !newEmail.isEmpty else { return }
        
        try await AuthenticationManager.shared.updateEmail(email: newEmail)
    }
}

@MainActor
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    @Binding var canChangeEmailDetails: Bool
    @Binding var showSigningView: Bool
    
    var body: some View {
        List {
            emailSection
            
            Button("Log out"){
                Task {
                    do {
                        try viewModel.signOut()
                        canChangeEmailDetails = false
                        showSigningView = true
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .alert(canChangeEmailDetails ? "" : "Oops!", isPresented: $viewModel.triggerEmailUpdate) {
            if canChangeEmailDetails {
                TextField("New email", text: $viewModel.newEmail)
                Button("Update email") {
                    Task {
                        do {
                            try await viewModel.updateEmail()
                            showSigningView = true
                            print("email updated!")
                        } catch {
                            print(error)
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } else {
                Button("OK") { }
            }
        } message: {
            Text(canChangeEmailDetails ? "" : "First, you have to log out in order to update the password")
        }
        .navigationTitle("Settings")
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Reset password"){
                Task {
                    do {
                        try await viewModel.resetPassword()
                        showSigningView = true
                        print("Password RESET!")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Update email") { viewModel.triggerEmailUpdate = true }
        } header: {
            Text("Email functions")
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(canChangeEmailDetails: .constant(true), showSigningView: .constant(false))
    }
}
