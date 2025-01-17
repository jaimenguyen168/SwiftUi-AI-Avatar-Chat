//
//  FileManagerUserPersistence.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/17/25.
//
import SwiftUI

struct FileManagerUserPersistence: LocalUserPersistenceService {
    
    let userDocumentKey: String = "current_user"
    
    func getCurrentUser() -> AppUser? {
        try? FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(_ user: AppUser?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
