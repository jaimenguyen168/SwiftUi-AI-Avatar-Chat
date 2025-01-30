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
    func fetchAllChats(userId: String) async throws -> [Chat]
    func addChatMessage(chatId: String, message: ChatMessage) async throws
    func getLastChatMessage(chatId: String) async throws -> ChatMessage?
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error>
}

struct MockChatService: ChatService {
    
    let chats: [Chat]
    let delay: Double
    let showError: Bool
    
    init(chats: [Chat] = Chat.mocks, delay: Double = 0, showError: Bool = false) {
        self.chats = chats
        self.delay = delay
        self.showError = showError
    }
    
    func createNewChat(chat: Chat) async throws {
        
    }
    
    func fetchChat(userId: String, avatarId: String) async throws -> Chat? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return chats.first { $0.userId == userId && $0.avatarId == avatarId }
        
    }
    
    func fetchAllChats(userId: String) async throws -> [Chat] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return chats
    }
    
    func addChatMessage(chatId: String, message: ChatMessage) async throws {
        
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessage? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ChatMessage.mockConversation.randomElement()
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { _ in
            
        }
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
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
    
    func fetchAllChats(userId: String) async throws -> [Chat] {
        try await collection
            .whereField(Chat.CodingKeys.userId.rawValue, isEqualTo: userId)
            .getAllDocuments()
        
        // sort in the view, not from server (for practices)
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
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessage? {
        let messages: [ChatMessage] = try await messagesCollection(for: chatId)
            .order(by: ChatMessage.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()
        
        return messages.first
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
    
    func fetchAllChats(userId: String) async throws -> [Chat] {
        try await service.fetchAllChats(userId: userId)
    }
    
    func addChatMessage(chatId: String, message: ChatMessage) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessage? {
        try await service.getLastChatMessage(chatId: chatId)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        service.streamChatMessages(chatId: chatId)
    }
}
