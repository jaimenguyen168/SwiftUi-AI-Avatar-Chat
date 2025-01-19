//
//  AIService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/18/25.
//

import SwiftUI

protocol AIService: Sendable {
    func generateImage(text: String) async throws -> UIImage
}
