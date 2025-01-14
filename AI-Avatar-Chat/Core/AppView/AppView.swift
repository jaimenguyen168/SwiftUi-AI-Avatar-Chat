//
//  AppView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct AppView: View {
    
    @State var appState: AppState = .init()
    @Environment(AuthManager.self) private var authManager
    
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
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserAuthentication()
                }
            }
        }
    }
}

private extension AppView {
    func checkUserAuthentication() async {
        if let user = authManager.authUser {
            print("User authenticated: \(user.uid)")
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                print("Sign in anonymously: \(result.user.uid)")
            } catch {
                print("DEBUG: \(error)")
            }
        }
    }
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(AuthManager(authService: MockAuthService(user: nil)))
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(AuthManager(authService: MockAuthService(user: nil)))
}
