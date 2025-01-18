//
//  AIManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/17/25.
//

import SwiftUI

@MainActor
@Observable
class AIManager {
    private let service: AIService
    
    init(aiService: AIService) {
        self.service = aiService
    }
    
    func generateImage(prompt: String) async throws -> UIImage {
        try await service.generateImage(text: prompt)
    }
}
