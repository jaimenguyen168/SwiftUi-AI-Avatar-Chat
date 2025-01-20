//
//  MockAvatarService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI

struct MockAvatarService: AvatarService {
    
    func createAvatar(_ avatar: Avatar, image: UIImage) async throws {

    }
    
    func getFeaturedAvatars() async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(1))
        return Avatar.mocks.shuffled()
    }
    
    func getPopularAvatars() async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(2))
        return Avatar.mocks.shuffled()
    }
    
    func getAvatarsForCategory(category: Character) async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(1))
        return Avatar.mocks.shuffled()
    }
    
    func getAvatarsForAuthor(authorId: String) async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(1))
        return Avatar.mocks.shuffled()
    }
}
