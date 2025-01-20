//
//  AvatarService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI

protocol AvatarService: Sendable {
    func createAvatar(_ avatar: Avatar, image: UIImage) async throws
    func getFeaturedAvatars() async throws -> [Avatar]
    func getPopularAvatars() async throws -> [Avatar]
    func getAvatarsForCategory(category: Character) async throws -> [Avatar]
    func getAvatarsForAuthor(authorId: String) async throws -> [Avatar]
}
