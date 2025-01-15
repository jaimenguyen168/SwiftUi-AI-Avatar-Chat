//
//  UserManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/14/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

protocol UserService: Sendable {
    func saveUser(user: AppUser) async throws
    func markOnboardingComplete(userId: String, profileColorHex: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<AppUser, Error>
    func deleteUser(userId: String) async throws
}

struct MockUserService: UserService {
    
    let currentUser: AppUser?
    
    init (user: AppUser? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: AppUser) async throws {}
    
    func markOnboardingComplete(userId: String, profileColorHex: String) async throws {}
    
    func streamUser(userId: String) -> AsyncThrowingStream<AppUser, any Error> {
        AsyncThrowingStream { subscriber in
            if let currentUser {
                subscriber.yield(currentUser)
            }
        }
    }
    
    func deleteUser(userId: String) async throws {}
}

struct FirebaseUserService: UserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: AppUser) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
    
    func markOnboardingComplete(userId: String, profileColorHex: String) async throws {
        try await collection.document(userId).updateData([
            AppUser.CodingKeys.didCompleteOnboarding.rawValue: true,
            AppUser.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<AppUser, Error> {
        collection.streamDocument(id: userId)
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
}

@MainActor
@Observable
class UserManager {
    
    private let userService: UserService
    private(set) var currentUser: AppUser?
    private var currentUserListener: ListenerRegistration?
    
    init(userService: UserService) {
        self.userService = userService
        self.currentUser = nil
    }
    
    func login(userAuth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = AppUser(authUser: userAuth, creationVersion: creationVersion)
        
        try await userService.saveUser(user: user)
        addCurrentUserListener(userId: userAuth.uid)
    }
    
    func addCurrentUserListener(userId: String) {
        currentUserListener?.remove()
        
        Task {
            do {
                for try await value in userService.streamUser(userId: userId) {
                    self.currentUser = value
                    print("Successfully listen to user data \(value.userId)")
                }
            } catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await userService.markOnboardingComplete(userId: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
    }
    
    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await userService.deleteUser(userId: uid)
        signOut()
    }
    
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
