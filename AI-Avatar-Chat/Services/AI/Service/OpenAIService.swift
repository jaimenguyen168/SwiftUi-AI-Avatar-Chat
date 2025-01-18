//
//  OpenAIService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/18/25.
//

import SwiftUI
import OpenAI

struct OpenAIService: AIService {
    
    var openAI: OpenAI {
        OpenAI(apiToken: Keys.openAIKey)
    }
    
    func generateImage(text: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: text,
            n: 1,
            quality: .hd,
            responseFormat: .b64_json,
            size: ._512,
            style: .natural,
            user: nil
        )
        
        let result = try await openAI.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data)
        else {
            throw OpenAIError.invalidResponse
        }
        
        return image
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}
