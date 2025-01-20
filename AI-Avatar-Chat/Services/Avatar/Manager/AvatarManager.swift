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
    private let service: AvatarService
    
    init(avatarService: AvatarService) {
        self.service = avatarService
    }
    
    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        try await service.createAvatar(avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [Avatar] {
        try await service.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [Avatar] {
        try await service.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: Character) async throws -> [Avatar] {
        try await service.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(authorId: String) async throws -> [Avatar] {
        try await service.getAvatarsForAuthor(authorId: authorId)
    }
}
