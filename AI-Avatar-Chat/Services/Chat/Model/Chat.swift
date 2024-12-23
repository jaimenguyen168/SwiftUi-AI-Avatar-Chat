//
//  Chat.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/22/24.
//

import Foundation
import SwiftUI

struct Chat: Identifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    
    static var mock: Chat {
        mocks[0]
    }
    
    static var mocks: [Chat] {
        (1...10).map { index in
            let now = Date()
            let dateCreated = now.addTimeInterval(days: index - 10)
            let dateModified = dateCreated.addTimeInterval(hours: index * 2)
            return Chat(
                id: UUID().uuidString,
                userId: "user_\(index)",
                avatarId: "avatar_\(index)",
                dateCreated: dateCreated,
                dateModified: dateModified
            )
        }
    }
}
