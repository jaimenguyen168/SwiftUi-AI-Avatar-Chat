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
    func fetchChat(userId: String, avatarId: String) async throws -> Chat?
    func addChatMessage(chatId: String, message: ChatMessage) async throws
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error>
}

struct MockChatService: ChatService {
    func createNewChat(chat: Chat) async throws {
        
    }
    
    func fetchChat(userId: String, avatarId: String) async throws -> Chat? {
        .mock
    }
    
    func addChatMessage(chatId: String, message: ChatMessage) async throws {
        
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { _ in
            
        }
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
    
    func fetchChat(userId: String, avatarId: String) async throws -> Chat? {
//        let result: [Chat] = try await collection
//            .whereField(Chat.CodingKeys.userId.rawValue, isEqualTo: userId)
//            .whereField(Chat.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
//            .getAllDocuments()
//        return result.first
        
        try await collection.getDocument(id: Chat.getChatId(by: userId, avatarId))
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
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        messagesCollection(for: chatId).streamAllDocuments()
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
    
    func fetchChat(userId: String, avatarId: String) async throws -> Chat? {
        try await service.fetchChat(userId: userId, avatarId: avatarId)
    }
    
    func addChatMessage(chatId: String, message: ChatMessage) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        service.streamChatMessages(chatId: chatId)
    }
}
