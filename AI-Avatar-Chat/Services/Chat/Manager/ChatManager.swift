//
//  ChatManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/26/25.
//

import SwiftUI
import FirebaseFirestore

protocol ChatService: Sendable {
    func createNewChat(chat: Chat) async throws
    func addChatMessage(chatId: String, message: ChatMessage) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: Chat) async throws {
        
    }
    
    func addChatMessage(chatId: String, message: ChatMessage) async throws {
        
    }
}

struct FirebaseChatService: ChatService {
    
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(for chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }
    
    func createNewChat(chat: Chat) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
    
    func addChatMessage(chatId: String, message: ChatMessage) async throws {
        try messagesCollection(for: chatId)
            .document(message.id)
            .setData(from: message, merge: true
        )
        
        try await collection
            .document(chatId)
            .updateData([Chat.CodingKeys.dateModified.rawValue: Date.now]
        )
    }
}

@MainActor
@Observable
class ChatManager {

    private var service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    func createNewChat(chat: Chat) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    func addChatMessage(chatId: String, message: ChatMessage) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
}
