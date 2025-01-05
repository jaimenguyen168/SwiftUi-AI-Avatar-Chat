//
//  AppAlert.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/5/25.
//

import SwiftUI

enum AlertType {
    case alert, confirmationDialog
}

struct AppAlert: Sendable {
    var title: String
    var subtitle: String?
    var buttons: @Sendable () -> AnyView
    
    init(
        title: String,
        subtitle: String? = nil,
        buttons: (@Sendable () -> AnyView)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons ?? {
            AnyView(Button("Ok") {})
        }
    }
    
    init(error: Error) {
        self.init(
            title: "Error",
            subtitle: error.localizedDescription,
            buttons: nil
        )
    }
}

extension View {
    @ViewBuilder
    func showCustomAlert(type: AlertType = .alert, alert: Binding<AppAlert?>) -> some View {
        switch type {
        case .alert:
            self
                .alert(alert.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: alert)) {
                    alert.wrappedValue?.buttons()
                } message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
        case .confirmationDialog:
            self
                .confirmationDialog(
                    alert.wrappedValue?.title ?? "",
                    isPresented: Binding(ifNotNil: alert)) {
                        alert.wrappedValue?.buttons()
                    } message: {
                        if let subtitle = alert.wrappedValue?.subtitle {
                            Text(subtitle)
                        }
                    }
                
        }
    }
}
