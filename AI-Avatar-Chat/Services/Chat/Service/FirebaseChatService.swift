//
//  FirebaseChatService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/1/25.
//

import SwiftUI
import FirebaseFirestore

struct FirebaseChatService: ChatService {
    
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messagesCollection(for chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }
    
    private var chatReportCollection: CollectionReference {
        Firestore.firestore().collection("chats_report")
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
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await messagesCollection(for: chatId).document(messageId).updateData([
            ChatMessage.CodingKeys.seenByIds.rawValue: FieldValue.arrayUnion([userId])
        ])
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
    
    func deleteChat(chatId: String) async throws {
        async let deletedChat: () = collection.deleteDocument(id: chatId)
        async let deleteMessages: () = messagesCollection(for: chatId).deleteAllDocuments()
        
        let (_, _) = await (try deletedChat, try deleteMessages)
    }
    
    func deleteAllChatsForUser(userId: String) async throws {
        let allChats = try await fetchAllChats(userId: userId)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for chat in allChats {
                group.addTask {
                    try await deleteChat(chatId: chat.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func reportChat(report: ChatReport) async throws {
        try await chatReportCollection.setDocument(document: report)
    }
}
