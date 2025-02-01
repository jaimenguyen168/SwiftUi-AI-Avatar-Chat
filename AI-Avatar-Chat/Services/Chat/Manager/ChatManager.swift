//
//  ChatManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/26/25.
//

import SwiftUI

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
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await service.markChatMessageAsSeen(chatId: chatId, messageId: messageId, userId: userId)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessage? {
        try await service.getLastChatMessage(chatId: chatId)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        service.streamChatMessages(chatId: chatId)
    }
    
    func deleteChat(chatId: String) async throws {
        try await service.deleteChat(chatId: chatId)
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        try await service.deleteAllChatsForUser(userId: userId)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        let report = ChatReport.newReport(chatId: chatId, userId: userId)
        try await service.reportChat(report: report)
    }
}
