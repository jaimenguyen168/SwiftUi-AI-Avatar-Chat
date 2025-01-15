//
//  UserManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/14/25.
//

import SwiftUI
import FirebaseFirestore

protocol UserService: Sendable {
    func saveUser(user: AppUser) async throws
}

struct FirebaseUserService: UserService {
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: AppUser) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }
}

@MainActor
@Observable
class UserManager {
    
    private let userService: UserService
    private(set) var currentUser: AppUser?
    
    init(userService: UserService) {
        self.userService = userService
        self.currentUser = nil
    }
    
    func login(userAuth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = AppUser(authUser: userAuth, creationVersion: creationVersion)
        
        try await userService.saveUser(user: user)
    }
}
