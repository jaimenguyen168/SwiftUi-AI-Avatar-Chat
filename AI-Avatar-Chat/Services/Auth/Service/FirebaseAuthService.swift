//
//  FirebaseAuthService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/10/25.
//

import FirebaseAuth
import SwiftUI
import SignInAppleAsync

struct FirebaseAuthService: AuthService {
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void)
    -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
            
            onListenerAttached(listener)
        }
    }
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(listener)
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        
        return nil
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthUserInfo
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = await SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        // link the account if user already signed in anonymously
        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                let result = try await user.link(with: credential)
                
                return result.asAuthUserInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCreditial = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let result = try await Auth.auth().signIn(with: secondaryCreditial)
                        return result.asAuthUserInfo
                    }
                default:
                    break
                }
            }
        }
        
        // otherwise sign in to new account
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthUserInfo
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.delete()
        } catch let error as NSError {
            let authError = AuthErrorCode(rawValue: error.code)
            switch authError {
            case .requiresRecentLogin:
                // try to re-auth
                try await reauthenticateUser(error: error)
                
                // if successful
                return try await user.delete()
            default:
                throw error
            }
        }
    }
    
    private func reauthenticateUser(error: Error) async throws {
        guard let user = Auth.auth().currentUser, let providerID = user.providerData.first?.providerID else {
            throw AuthError.userNotFound
        }
        
        let uid = user.uid
        
        switch providerID {
        case "apple.com":
            let result = try await signInWithApple()
            
            guard user.uid == result.user.uid else {
                throw AuthError.reauthAccountChanged
            }
        default:
            throw error
        }
    }
}

enum AuthError: LocalizedError {
    case userNotFound
    case reauthAccountChanged
    
    var localizedDescription: String {
        switch self {
        case .userNotFound:
            return "Current Authenticated User not found"
        case .reauthAccountChanged:
            return "Reauthentication required. Please sign in again with your current credentials."
        }
    }
}

extension AuthDataResult {
    var asAuthUserInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }
}
