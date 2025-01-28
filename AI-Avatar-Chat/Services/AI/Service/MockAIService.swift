//
//  MockAIService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/18/25.
//

import SwiftUI

struct MockAIService: AIService {
    
    let delay: Double
    let showError: Bool
    
    init(delay: Double = 0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    func generateImage(text: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        try showCustomError()
        return UIImage(systemName: "person.circle")!
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await Task.sleep(for: .seconds(delay))
        try showCustomError()
        return AIChatModel(role: .assistant, content: "Message from the so-called AI assistant")
    }
    
    private func showCustomError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}
