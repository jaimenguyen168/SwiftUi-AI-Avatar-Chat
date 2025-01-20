//
//  LocalAvatarPersistence.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI

@MainActor
protocol LocalAvatarPersistence {
    func addRecentAvatar(_ avatar: Avatar) throws
    func getRecentAvatars() throws -> [Avatar]
}
