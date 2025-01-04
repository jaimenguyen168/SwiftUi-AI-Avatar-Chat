//
//  ChatMessage.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/23/24.
//

import Foundation

struct ChatMessage: Hashable, Identifiable {
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
    
    func hasBeenSeenByCurrentUser(userId: String) -> Bool {
        guard let seenByIds else { return false }
        return seenByIds.contains(userId)
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
    
    static var mockConversation: [ChatMessage] {
            let now = Date()
            let chatId = UUID().uuidString
            return [
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser1",
                    content: "Hey, how's it going?",
                    seenByIds: ["user_2"],
                    dateCreated: now.addTimeInterval(minutes: -50)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser2",
                    content: "Pretty good, how about you?",
                    seenByIds: ["user_1"],
                    dateCreated: now.addTimeInterval(minutes: -48)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser1",
                    content: "Not bad, just been busy with work lately.",
                    seenByIds: ["user_2"],
                    dateCreated: now.addTimeInterval(minutes: -46)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser2",
                    content: "I hear you! Same here. What’s keeping you busy?",
                    seenByIds: ["user_1"],
                    dateCreated: now.addTimeInterval(minutes: -44)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser1",
                    content: "Mainly wrapping up a new project. It’s been intense.",
                    seenByIds: ["user_2"],
                    dateCreated: now.addTimeInterval(minutes: -42)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser2",
                    content: "That sounds exciting! What's the project about?",
                    seenByIds: ["user_1"],
                    dateCreated: now.addTimeInterval(minutes: -40)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser1",
                    content: "It’s a new app for managing personal finances. Still a lot to do!",
                    seenByIds: ["user_2"],
                    dateCreated: now.addTimeInterval(minutes: -38)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser2",
                    content: "That sounds useful. Let me know when it's done!",
                    seenByIds: ["user_1"],
                    dateCreated: now.addTimeInterval(minutes: -36)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser1",
                    content: "Will do! How’s everything on your end?",
                    seenByIds: ["user_2"],
                    dateCreated: now.addTimeInterval(minutes: -34)
                ),
                ChatMessage(
                    id: UUID().uuidString,
                    chatId: chatId,
                    authorId: "mockUser2",
                    content: "Busy, but good. Let’s catch up more soon!",
                    seenByIds: ["user_1"],
                    dateCreated: now.addTimeInterval(minutes: -32)
                )
            ]
        }
}
