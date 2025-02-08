//
//  LogManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/8/25.
//

import SwiftUI

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any])
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

struct ConsoleService: LogService {
    func identifyUser(userId: String, name: String?, email: String?) {
        let resultString = """
Identify User:
    userId: \(userId)
    name: \(name ?? "unknown")
    email: \(email ?? "unknown")
"""
        print(resultString)
    }
    
    func addUserProperties(dict: [String: Any]) {
        var resultString = """
Log User Properties:
"""
        let sortedKeys = dict.keys.sorted()
        for key in sortedKeys {
            if let value = dict[key] as? String {
                resultString += "\n\t(key: \(key), value: \(value))"
            }
        }
        print(resultString)
    }
    
    func deleteUserProfile() {
        let resultString = "Delete User Profile"
        print(resultString)
    }
    
    func trackEvent(event: any LoggableEvent) {
        var resultString = "\(event.eventName)"
        if let parameters = event.parameters, !parameters.isEmpty {
            let sortedKeys = parameters.keys.sorted()
            for key in sortedKeys {
                if let value = parameters[key] as? String {
                    resultString += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        print(resultString)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        trackEvent(event: event)
    }
}

@MainActor
@Observable
class LogManager {
    
    private let services: [LogService]
    
    init(services: [LogService] = []) {
        self.services = services
    }
    
    func identifyUser(userId: String, name: String?, email: String?) {
        for service in services {
            service.identifyUser(userId: userId, name: name, email: email)
        }
    }
    
    func addUserProperties(dict: [String: Any]) {
        for service in services {
            service.addUserProperties(dict: dict)
        }
    }
    
    func deleteUserProfile() {
        for service in services {
            service.deleteUserProfile()
        }
    }

    func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        for service in services {
            service.trackScreenEvent(event: event)
        }
    }
}
