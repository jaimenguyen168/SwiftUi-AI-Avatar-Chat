//
//  UserManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/14/25.
//

import SwiftUI

@MainActor
@Observable
class UserManager {
    
    private let remote: RemoteUserService
    private let local: LocalUserPersistenceService
    private(set) var currentUser: AppUser?
    private var currentUserListener: ListenerRegistration?
    
    init(userServices: UserServices) {
        self.remote = userServices.remote
        self.local = userServices.local
        self.currentUser = local.getCurrentUser()
        print("Loaded current user: \(String(describing: currentUser))")
        print(NSHomeDirectory())
    }
    
    func login(userAuth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = AppUser(authUser: userAuth, creationVersion: creationVersion)
        
        try await remote.saveUser(user: user)
        addCurrentUserListener(userId: userAuth.uid)
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingComplete(userId: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
    }
    
    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        signOut()
    }
    
    private func addCurrentUserListener(userId: String) {
        currentUserListener?.remove()
        
        Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value
                    saveCurrentUserLocally()
                    print("Successfully listen to user data \(value.userId)")
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
    }
    
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    private func saveCurrentUserLocally() {
        Task {
            do {
                try local.saveCurrentUser(currentUser)
                print("SUCCESS: Saved user locally")
            } catch {
                print("DEBUG: Failed to save user locally \(error.localizedDescription)")
            }
        }
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
 
