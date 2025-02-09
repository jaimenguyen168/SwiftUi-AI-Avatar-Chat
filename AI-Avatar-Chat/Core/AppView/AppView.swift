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
    @Environment(UserManager.self) private var userManager
    
    @Environment(LogManager.self) private var logManager
    
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
        .onAppear {
            logManager.trackEvent(event: Event.alpha)
            logManager.trackEvent(event: Event.beta)
            logManager.trackEvent(event: Event.gamma)
            logManager.trackEvent(event: Event.delta)
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

// MARK: Additional Data Section
private extension AppView {
    enum Event: LoggableEvent {
        case alpha, beta, gamma, delta
        
        var eventName: String {
            switch self {
            case .alpha: "Alpha"
            case .beta: "Beta"
            case .gamma: "Gamma"
            case .delta: "Delta"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .alpha, .beta: return ["aaa": 111, "bbb": true]
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .alpha: .info
            case .beta: .analytic
            case .gamma: .warning
            case .delta: .severe
            }
        }
    }
}

// MARK: Logic Section
private extension AppView {
    func checkUserAuthentication() async {
        if let user = authManager.authUser {
            print("User authenticated: \(user.uid)")
            
            do {
                try await userManager.login(userAuth: user, isNewUser: false)
            } catch {
                print("DEBUG: failed to log in for existing user \(error.localizedDescription)")
                try? await Task.sleep(for: .seconds(2))
                await checkUserAuthentication()
            }
        } else {
            do {
                let result = try await authManager.signInAnonymously()
                print("Sign in anonymously: \(result.user.uid)")
                
                try await userManager.login(userAuth: result.user, isNewUser: result.isNewUser)
            } catch {
                print("DEBUG: failed to sign in anonymously \(error)")
                try? await Task.sleep(for: .seconds(2))
                await checkUserAuthentication()
            }
        }
    }
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(AuthManager(authService: MockAuthService(authUser: nil)))
        .environment(UserManager(userServices: MockUserServices(user: nil)))
        .previewAllEnvironments()
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(AuthManager(authService: MockAuthService(authUser: .mock())))
        .environment(UserManager(userServices: MockUserServices(user: .mock)))
        .previewAllEnvironments()
}
