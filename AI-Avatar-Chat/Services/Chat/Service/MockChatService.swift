//
//  MockChatService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/1/25.
//
import SwiftUI

@MainActor
class MockChatService: ChatService {
    
    let chats: [Chat]
    @Published private var messages: [ChatMessage]
    let delay: Double
    let showError: Bool
    
    init(
        chats: [Chat] = Chat.mocks,
        messages: [ChatMessage] = ChatMessage.mockConversation,
        delay: Double = 0,
        showError: Bool = false
    ) {
        self.chats = chats
        self.messages = messages
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
        messages.append(message)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessage? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ChatMessage.mockConversation.randomElement()
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(messages)
            
            Task {
                for await value in $messages.values {
                    continuation.yield(value)
                }
            }
        }
    }
    
    func deleteChat(chatId: String) async throws {

    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        
    }
    
    func reportChat(report: ChatReport) async throws {
        
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}
