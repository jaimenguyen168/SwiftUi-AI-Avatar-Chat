//
//  MockAIService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/18/25.
//

import SwiftUI

struct MockAIService: AIService {
    func generateImage(text: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        return UIImage(systemName: "person.circle")!
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await Task.sleep(for: .seconds(2))
        return AIChatModel(role: .assistant, content: "Message from the so-called AI assistant")
    }
}
