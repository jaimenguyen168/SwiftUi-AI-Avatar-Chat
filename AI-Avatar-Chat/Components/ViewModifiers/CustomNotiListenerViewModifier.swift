//
//  CustomNotiListenerViewModifier.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 3/1/25.
//

import SwiftUI

public struct CustomNotiListenerViewModifier: ViewModifier {
    
    let notificationName: Notification.Name
    let onNotificationReceived: @MainActor (Notification) -> Void
    
    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: notificationName)) { notification in
                onNotificationReceived(notification)
            }
    }
}

extension View {
    public func onCustomNotificationReceived(
        name: Notification.Name,
        action: @MainActor @escaping (Notification) -> Void
    ) -> some View {
        modifier(CustomNotiListenerViewModifier(notificationName: name, onNotificationReceived: action))
    }
}
