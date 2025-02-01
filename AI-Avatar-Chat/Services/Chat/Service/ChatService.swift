//
//  ChatService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/1/25.
//

import Foundation

protocol ChatService: Sendable {
    func createNewChat(chat: Chat) async throws
    func fetchChat(userId: String, avatarId: String) async throws -> Chat?
    func fetchAllChats(userId: String) async throws -> [Chat]
    func addChatMessage(chatId: String, message: ChatMessage) async throws
    func getLastChatMessage(chatId: String) async throws -> ChatMessage?
    
    @MainActor
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error>
    func deleteChat(chatId: String) async throws
    func deleteAllChatsForUser(userId: String) async throws
    func reportChat(report: ChatReport) async throws
}
