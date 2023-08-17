//
//  AuthenticationView.swift
//  HappyFace
//
//  Created by Piotr Woźniak on 07/08/2023.
//

import SwiftUI

struct AuthenticationView: View {
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
