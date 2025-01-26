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
}

struct MockChatService: ChatService {
    func createNewChat(chat: Chat) async throws {
        
    }
}

struct FirebaseChatService: ChatService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    func createNewChat(chat: Chat) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
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
}
