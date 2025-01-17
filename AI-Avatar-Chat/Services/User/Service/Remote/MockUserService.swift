//
//  MockUserService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/17/25.
//
import SwiftUI

struct MockUserService: RemoteUserService {
    
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
