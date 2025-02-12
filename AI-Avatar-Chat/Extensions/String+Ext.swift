//
//  String+Ext.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/12/25.
//

import Foundation

extension String {
    
    static func convertToString(_ value: Any) -> String? {
        switch value {
        case let value as Date:
            return value.formatted(date: .abbreviated, time: .shortened)
        case let value as [Any]:
            return value.compactMap({ String(describing: $0) }).sorted().joined(separator: ", ")
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value) as String? ?? "Unknown"
        }
    }
}

extension String {
    func clipped(maxCharacters: Int) -> String {
        String(prefix(maxCharacters))
    }
    
    func replaceSpacesWithUnderscores() -> String {
        replacingOccurrences(of: " ", with: "_")
    }
}
