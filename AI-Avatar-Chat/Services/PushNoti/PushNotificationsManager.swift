//
//  PushNotificationsManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/25/25.
//

import Foundation
import SwiftfulUtilities

@MainActor
@Observable
class PushNotificationsManager {
    
    private let logManager: LogManager?
    
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
    
    func requestAuthorization() async throws -> Bool {
        let isASuthorized = try await LocalNotifications.requestAuthorization()
        
        logManager?.addUserProperties(
            dict: ["push_is_authorized": isASuthorized],
            isHighPriority: true
        )
        
        return isASuthorized
    }
    
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    
    func schedulePushNotificationForNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                // Tomorrow
                try await scheduleNotification(
                    title: "Hello You",
                    subtitle: "Open the app to begin chatting",
                    triggerDate: Date().addTimeInterval(days: 1)
                )
                
                // In 3 days
                try await scheduleNotification(
                    title: "Someone sent a message",
                    subtitle: "Open the app to respond",
                    triggerDate: Date().addTimeInterval(days: 3)
                )
                
                // In 1 week
                try await scheduleNotification(
                    title: "We miss you",
                    subtitle: "Open the app to reconnect",
                    triggerDate: Date().addTimeInterval(days: 7)
                )
                
                logManager?.trackEvent(event: Event.weekScheduleSuccess)
            } catch {
                logManager?.trackEvent(event: Event.weekScheduleFailed(error: error))
            }
        }
    }
                                                                  
    func scheduleNotification(title: String, subtitle: String, triggerDate: Date) async throws {
        let content = AnyNotificationContent(title: title, body: subtitle)
        let date = triggerDate
        let trigger = NotificationTriggerOption.date(date: date, repeats: false)
        try await LocalNotifications.scheduleNotification(content: content, trigger: trigger)
    }
}

// MARK: Additional Data Section
private extension PushNotificationsManager {
    enum Event: LoggableEvent {
        case weekScheduleSuccess
        case weekScheduleFailed(error: Error)
        
        var eventName: String {
            switch self {
            case .weekScheduleSuccess:  "PushManager_WeekSchedule_Success"
            case .weekScheduleFailed:   "PushManager_WeekSchedule_Failed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .weekScheduleFailed(error: let error):
                return error.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .weekScheduleFailed: .severe
            default: .analytic
            }
        }
    }
}
