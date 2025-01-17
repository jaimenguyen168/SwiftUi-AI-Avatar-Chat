//
//  LocalUserPersistenceService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/17/25.
//
import Foundation

protocol LocalUserPersistenceService {
    func getCurrentUser() -> AppUser?
    func saveCurrentUser(_ user: AppUser?) throws
}
