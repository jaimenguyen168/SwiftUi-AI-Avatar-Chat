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
        .screenAppearAnalytics(name: "AppView")
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
        case existingAuthStart
        case existingAuthFailed(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFailed(error: Error)
        
        var eventName: String {
            switch self {
            case .existingAuthStart: "AppView_ExistingAuth_Start"
            case .existingAuthFailed: "AppView_ExistingAuth_Failed"
            case .anonAuthStart: "AppView_AnonAuth_Start"
            case .anonAuthSuccess: "AppView_AnonAuth_Success"
            case .anonAuthFailed: "AppView_AnonAuth_Failed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFailed(error: let error), .anonAuthFailed(error: let error):
                return error.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .existingAuthFailed, .anonAuthFailed: .severe
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension AppView {
    func checkUserAuthentication() async {
        if let user = authManager.authUser {
            logManager.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await userManager.login(userAuth: user, isNewUser: false)
            } catch {
                logManager.trackEvent(event: Event.existingAuthFailed(error: error))
                try? await Task.sleep(for: .seconds(2))
                await checkUserAuthentication()
            }
        } else {
            logManager.trackEvent(event: Event.anonAuthStart)
            
            do {
                let result = try await authManager.signInAnonymously()
                
                logManager.trackEvent(event: Event.anonAuthSuccess)
                try await userManager.login(userAuth: result.user, isNewUser: result.isNewUser)
            } catch {
                logManager.trackEvent(event: Event.anonAuthFailed(error: error))
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
