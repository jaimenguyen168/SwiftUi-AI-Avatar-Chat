//
//  AvatarService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI

protocol RemoteAvatarService: Sendable {
    func createAvatar(_ avatar: Avatar, image: UIImage) async throws
    func getFeaturedAvatars() async throws -> [Avatar]
    func getPopularAvatars() async throws -> [Avatar]
    func getAvatarsForCategory(category: Character) async throws -> [Avatar]
    func getAvatarsForAuthor(authorId: String) async throws -> [Avatar]
    func getAvatar(id: String) async throws -> Avatar
    func incrementAvatarClickCount(avatarId: String) async throws
}
