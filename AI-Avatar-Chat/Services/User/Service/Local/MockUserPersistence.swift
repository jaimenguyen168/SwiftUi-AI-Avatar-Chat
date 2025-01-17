//
//  MockUserPersistence.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/17/25.
//
import Foundation

struct MockUserPersistence: LocalUserPersistenceService {
    
    let currentUser: AppUser?
    
    init (user: AppUser? = nil) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> AppUser? { currentUser }
    func saveCurrentUser(_ user: AppUser?) throws {}
}
