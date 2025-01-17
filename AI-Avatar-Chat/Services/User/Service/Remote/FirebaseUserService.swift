//
//  FirebaseUserService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/17/25.
//
import SwiftUI
import FirebaseFirestore
import SwiftfulFirestore

typealias ListenerRegistration = FirebaseFirestore.ListenerRegistration

struct FirebaseUserService: RemoteUserService {
    
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
