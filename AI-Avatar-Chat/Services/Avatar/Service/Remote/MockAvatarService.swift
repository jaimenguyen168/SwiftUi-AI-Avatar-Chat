//
//  MockAvatarService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    
    var avatars: [Avatar]
    let delay: Double
    let showError: Bool
    
    init(avatars: [Avatar] = Avatar.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.avatars = avatars
        self.delay = delay
        self.showError = showError
    }
    
    func createAvatar(_ avatar: Avatar, image: UIImage) async throws {
        try showCustomError()
    }
    
    func getFeaturedAvatars() async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(delay))
        try showCustomError()
        return avatars.shuffled()
    }
    
    func getPopularAvatars() async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(delay))
        try showCustomError()
        return avatars.shuffled()
    }
    
    func getAvatarsForCategory(category: Character) async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(delay))
        try showCustomError()
        return avatars.shuffled()
    }
    
    func getAvatarsForAuthor(authorId: String) async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(delay))
        try showCustomError()
        return avatars.shuffled()
    }
    
    func getAvatar(id: String) async throws -> Avatar {
        try showCustomError()
        guard let avatar = avatars.first(where: { $0.avatarId == id }) else {
            throw URLError(.noPermissionsToReadFile)
        }
        
        return avatar
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        
    }
    
    private func showCustomError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}
