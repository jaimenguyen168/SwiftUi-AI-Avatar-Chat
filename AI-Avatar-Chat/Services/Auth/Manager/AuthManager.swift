//
//  AuthManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/14/25.
//

import SwiftUI

@MainActor
@Observable
class AuthManager {
    
    private let authService: AuthService
    private(set) var authUser: UserAuthInfo?
    private var authListener: (any NSObjectProtocol)?
    
    init(authService: AuthService) {
        self.authService = authService
        self.authUser = authService.getAuthenticatedUser()
        self.addAuthListeners()
    }
    
    private func addAuthListeners() {
        Task {
            for await value in authService.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.authListener = listener
            }) {
                self.authUser = value
                print("Auth Listeners successfully attached: \(value?.uid ?? "No user")")
            }
        }
    }
    
    func getAuthId() throws -> String {
        guard let uid = authUser?.uid else {
            throw AuthError.notSignIn
        }
        return uid
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authService.signInAnonymously()
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authService.signInWithApple()
    }
    
    func signOut() throws {
        try authService.signOut()
        authUser = nil
    }
    
    func deleteAccount() async throws {
        try await authService.deleteAccount()
        authUser = nil
    }
    
    enum AuthError: LocalizedError {
        case notSignIn
    }
}
