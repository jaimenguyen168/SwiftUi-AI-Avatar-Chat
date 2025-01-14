//
//  CreateAccountView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/24/24.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account information."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 55)
            .customButton(.pressable) {
                onSignInWithApplePress()
            }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
}

private extension CreateAccountView {
    func onSignInWithApplePress() {
        Task {
            do {
                let result = try await authManager.signInWithApple()
                onDidSignIn?(result.isNewUser)
                print("DEBUG: Did sign in with Apple")
                dismiss()
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CreateAccountView()
        .environment(AuthManager(authService: MockAuthService(user: nil)))
}
