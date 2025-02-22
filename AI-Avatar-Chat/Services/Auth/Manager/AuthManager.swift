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
    private let logManager: LogManager?
    
    private(set) var authUser: UserAuthInfo?
    private var authListener: (any NSObjectProtocol)?
    
    init(authService: AuthService, logManager: LogManager? = nil) {
        self.authService = authService
        self.authUser = authService.getAuthenticatedUser()
        self.logManager = logManager
        
        self.addAuthListeners()
    }
    
    private func addAuthListeners() {
        logManager?.trackEvent(event: Event.authListenerStart)
        
        Task {
            for await value in authService.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.authListener = listener
            }) {
                self.authUser = value
                logManager?.trackEvent(event: Event.authListenerSuccess(value))
                
                if let value {
                    logManager?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    logManager?.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
                }
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
        logManager?.trackEvent(event: Event.signOutStart)
        
        try authService.signOut()
        authUser = nil
        
        logManager?.trackEvent(event: Event.signOutSuccess)
    }
    
    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        try await authService.deleteAccount()
        authUser = nil
        
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
    }
}

// MARK: Additional Data Section
private extension AuthManager {
    enum AuthError: LocalizedError {
        case notSignIn
    }
    
    enum Event: LoggableEvent {
        case authListenerStart
        case authListenerSuccess(UserAuthInfo?)
        case signOutStart
        case signOutSuccess
        case deleteAccountStart
        case deleteAccountSuccess
        
        var eventName: String {
            switch self {
            case .authListenerStart:      "AuthManager_RemoteListener_Start"
            case .authListenerSuccess:    "AuthManager_RemoteListener_Success"
            case .signOutStart:           "AuthManager_SignOut_Start"
            case .signOutSuccess:         "AuthManager_SignOut_Success"
            case .deleteAccountStart:     "AuthManager_DeleteAccount_Start"
            case .deleteAccountSuccess:   "AuthManager_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(let authUser):
                return authUser?.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            default: .analytic
            }
        }
    }
}
