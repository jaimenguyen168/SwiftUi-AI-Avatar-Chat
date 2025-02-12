//
//  LoggableEvent.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/9/25.
//

import SwiftUI

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var logType: LogType { get }
}

struct AnyLoggableEvent: LoggableEvent {
    let eventName: String
    let parameters: [String: Any]?
    let logType: LogType
    
    init(
        eventName: String,
        parameters: [String: Any]? = nil,
        logType: LogType = .analytic
    ) {
        self.eventName = eventName
        self.parameters = parameters
        self.logType = logType
    }
}
