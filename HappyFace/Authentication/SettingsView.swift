//
//  SettingsView.swift
//  HappyFace
//
//  Created by Piotr Woźniak on 07/08/2023.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let user = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = user.email else { throw URLError(.fileDoesNotExist) }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSigningView: Bool
    
    var body: some View {
        List {
            Button("Log out"){
                Task {
                    do {
                        try viewModel.signOut()
                        showSigningView = true
                    } catch {
                        print(error)
                    }
                }
            }
            
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
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSigningView: .constant(false))
    }
}
