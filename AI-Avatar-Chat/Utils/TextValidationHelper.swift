//
//  TextValidationHelper.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/4/25.
//

import SwiftUI

enum TextValidationError: LocalizedError {
    case notEnoughCharacters(min: Int)
    case hasBadWords
    
    var errorDescription: String? {
        switch self {
        case .notEnoughCharacters(min: let min):
            "Please has at least \(min) characters"
        case .hasBadWords:
            "Bad words detected. Please consider to change it."
        }
    }
}

struct TextValidationHelper {
    static func validateText(text: String) throws {
        let minimumLength = 3
        
        guard text.count >= minimumLength else { throw TextValidationError.notEnoughCharacters(min: minimumLength) }
        
        let badWords: [String] = [
            "ass", "bad", "pussy"
        ]
        
        if badWords.contains(text.lowercased()) {
            throw TextValidationError.hasBadWords
        }
    }
}
