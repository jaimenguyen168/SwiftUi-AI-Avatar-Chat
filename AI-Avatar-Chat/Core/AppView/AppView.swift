//
//  AppView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct AppView: View {
    
    @State var appState: AppState = .init()
    @Environment(\.authService) private var authService
    
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabBarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .environment(appState)
        .task {
            await checkUserAuthentication()
        }
    }
}

private extension AppView {
    func checkUserAuthentication() async {
        if let user = authService.getAuthenticatedUser() {
            print("User authenticated: \(user.uid)")
        } else {
            do {
                let result = try await authService.signInAnonymously()
                print("Sign in anonymously: \(result.user.uid)")
            } catch {
                print("DEBUG: \(error)")
            }
        }
    }
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}
