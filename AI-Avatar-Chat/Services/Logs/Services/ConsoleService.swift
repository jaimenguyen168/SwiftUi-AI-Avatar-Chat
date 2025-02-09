//
//  ConsoleService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/8/25.
//
import SwiftUI
import OSLog

actor LogSystem {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConsoleLogger")
    
    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
    
    nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.toOSLogType, message: message)
        }
    }
}

enum LogType {
    /// General information that is not analytic, warning, or error
    case info
    
    /// Default type for analytics
    case analytic
    
    /// Issues or errors that should not occur but will negatively affect UX
    case warning
    
    /// Issues or erros that will negatively affect UX
    case severe
    
    var toOSLogType: OSLogType {
        switch self {
        case .info:
            return .info
        case .analytic:
            return .default
        case .warning:
            return .error
        case .severe:
            return .fault
        }
    }
    
    var emoji: String {
        switch self {
        case .info:
            return "✨"
        case .analytic:
            return "📈"
        case .warning:
            return "⚠️"
        case .severe:
            return "‼️"
        }
    }
}

struct ConsoleService: LogService {
    
    let logger = LogSystem()
    private let printParameters: Bool
    
    init(printParameters: Bool = false) {
        self.printParameters = printParameters
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        let resultString = """
📈 Identify User:
    userId: \(userId)
    name: \(name ?? "unknown")
    email: \(email ?? "unknown")
"""
        logger.log(level: LogType.info, message: resultString)
    }
    
    func addUserProperties(dict: [String: Any]) {
        var resultString = """
📈 Log User Properties:
"""
        if printParameters {
            let sortedKeys = dict.keys.sorted()
            for key in sortedKeys {
                if let value = dict[key] as? String {
                    resultString += "\n\t(key: \(key), value: \(value))"
                }
            }
        }
        
        logger.log(level: LogType.info, message: resultString)
    }
    
    func deleteUserProfile() {
        let resultString = "📈 Delete User Profile"
        
        logger.log(level: LogType.info, message: resultString)
    }
    
    func trackEvent(event: LoggableEvent) {
        var resultString = "\(event.logType.emoji) \(event.eventName)"
        
        if printParameters, let parameters = event.parameters, !parameters.isEmpty {
            let sortedKeys = parameters.keys.sorted()
            for key in sortedKeys {
                if let value = parameters[key] {
                    resultString += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        logger.log(level: event.logType, message: resultString)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        trackEvent(event: event)
    }
}
