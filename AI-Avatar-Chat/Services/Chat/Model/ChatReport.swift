//
//  ChatReport.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/1/25.
//

import Foundation
import IdentifiableByString

struct ChatReport: Codable, StringIdentifiable {
    let id: String
    let chatId: String
    let userId: String
    let isActive: Bool
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case userId = "user_id"
        case isActive = "is_active"
        case dateCreated = "date_created"
    }
    
    static func newReport(chatId: String, userId: String) -> Self {
        .init(
            id: "\(userId)_\(chatId)",
            chatId: chatId,
            userId: userId,
            isActive: true,
            dateCreated: .now
        )
    }
}
