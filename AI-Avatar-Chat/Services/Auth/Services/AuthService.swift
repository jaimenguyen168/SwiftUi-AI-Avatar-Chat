//
//  AuthService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/13/25.
//
import SwiftUI

protocol AuthService: Sendable {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void)
    -> AsyncStream<UserAuthInfo?>
    func getAuthenticatedUser() -> UserAuthInfo?
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}

// swiftlint:disable comment_spacing
//extension EnvironmentValues {
//    @Entry var authService: AuthService = MockAuthService()
//}
// swiftlint:enable comment_spacing

