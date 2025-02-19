//
//  AppearAnalyticsViewModifier.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/18/25.
//

import SwiftUI

struct AppearAnalyticsViewModifier: ViewModifier {
    
    @Environment(LogManager.self) private var logManager
    let name: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                logManager.trackScreenEvent(event: Event.appear(name: name))
            }
            .onDisappear {
                logManager.trackScreenEvent(event: Event.disappear(name: name))
            }
    }
    
    enum Event: LoggableEvent {
        case appear(name: String), disappear(name: String)
        
        var eventName: String {
            switch self {
            case .appear(name: let name): "\(name)_Appear"
            case .disappear(name: let name): "\(name)_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            return nil
        }
        
        var logType: LogType {
            .analytic
        }
    }
}

extension View {
    func screenAppearAnalytics(name: String) -> some View {
        modifier(AppearAnalyticsViewModifier(name: name))
    }
}
