//
//  MockLocalAvatarPersistence.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI

@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    func removeAllRecentAvatars() throws {
        
    }
    
    func addRecentAvatar(_ avatar: Avatar) throws {
        
    }
    
    func getRecentAvatars() throws -> [Avatar] {
        Avatar.mocks.shuffled()
    }
}
