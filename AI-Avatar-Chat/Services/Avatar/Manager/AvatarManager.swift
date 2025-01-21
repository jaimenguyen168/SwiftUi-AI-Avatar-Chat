//
//  AvatarManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/18/25.
//

import SwiftUI

@MainActor
@Observable
class AvatarManager {
    private let remote: RemoteAvatarService
    private let local: LocalAvatarPersistence
    
    init(avatarService: RemoteAvatarService, localService: LocalAvatarPersistence = MockLocalAvatarPersistence()) {
        self.remote = avatarService
        self.local = localService
    }
    
    func addRecentAvatar(_ avatar: Avatar) async throws {
        try local.addRecentAvatar(avatar)
        try await remote.incrementAvatarClickCount(avatarId: avatar.avatarId)
    }
    
    func getRecentAvatars() throws -> [Avatar] {
        try local.getRecentAvatars()
    }
    
    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        try await remote.createAvatar(avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [Avatar] {
        try await remote.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [Avatar] {
        try await remote.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: Character) async throws -> [Avatar] {
        try await remote.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(authorId: String) async throws -> [Avatar] {
        try await remote.getAvatarsForAuthor(authorId: authorId)
    }
    
    func getAvatarById(_ id: String) async throws -> Avatar? {
        try await remote.getAvatar(id: id)
    }
}
