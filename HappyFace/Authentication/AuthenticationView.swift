//
//  AuthenticationView.swift
//  HappyFace
//
//  Created by Piotr Woźniak on 07/08/2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var didSignInWithApple: Bool = false
    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
    
    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do { 
                        try await AuthenticationManager.shared.signInWithApple(tokens: signInAppleResult)
                        self.didSignInWithApple = true
                    } catch {
                        
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    @Binding var canChangeEmailDetails: Bool
    @Binding var showSignInView: Bool 
    
    var body: some View {
        VStack {
            NavigationLink {
                SignInEmailView(canChangeEmailDetails: $canChangeEmailDetails, showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.signInApple()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .allowsHitTesting(false)
            }
            .frame(height: 55)
            .onChange(of: viewModel.didSignInWithApple) { newValue in
                if newValue == true {
                    showSignInView = false
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(canChangeEmailDetails: .constant(false), showSignInView: .constant(false))
        }
    }
}
