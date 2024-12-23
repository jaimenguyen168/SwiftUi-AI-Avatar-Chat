//
//  ChatMessage.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/23/24.
//

import Foundation

struct ChatMessage {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
        seenByIds: [String]? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }
    
    static var mock: ChatMessage {
        mocks[0]
    }
    
    static var mocks: [ChatMessage] {
        let now = Date()
        return (1...10).map { index in
            ChatMessage(
                id: UUID().uuidString,
                chatId: Chat.mocks[Int.random(in: 0..<Chat.mocks.count)].id,
                authorId: "user_\(Int.random(in: 1...10))",
                content: "Message content \(index)",
                seenByIds: (1...index).compactMap { $0 % 2 == 0 ? "user_\($0)" : nil },
                dateCreated: now.addTimeInterval(minutes: index * -5)
            )
        }
    }
}
