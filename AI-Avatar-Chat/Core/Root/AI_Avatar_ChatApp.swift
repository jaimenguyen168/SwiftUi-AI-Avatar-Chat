//
//  AI_Avatar_ChatApp.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI
import FirebaseCore

@main
struct AIAvatarChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.pushNotificationsManager)
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.logManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var dependencies: Dependency!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        let config: BuildConfiguration
        
        #if MOCK
        // MARK: - Mock Dependency Scheme
        config = .mock(isSignedIn: true)
        #elseif DEV
        // MARK: - Production Dependency Scheme + Extra Dev Tools
        config = .development
        #else
        // MARK: - Production Dependency Scheme
        config = .production
        #endif
        
        config.configure()
        dependencies = Dependency(config)
        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), development, production
    
    func configure() {
        switch self {
        case .mock:
            break
        case .development:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .production:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}

@MainActor
struct Dependency {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    
    let logManager: LogManager
    let pushNotificationsManager: PushNotificationsManager
    
    init(_ config: BuildConfiguration) {
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            self.logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            
            self.authManager = AuthManager(authService: MockAuthService(
                authUser: isSignedIn ? .mock() : nil), logManager: logManager)
            self.userManager = UserManager(userServices: MockUserServices(
                user: isSignedIn ? .mock : nil), logManager: logManager)
            self.aiManager = AIManager(aiService: MockAIService(delay: 2))
            self.avatarManager = AvatarManager(
                avatarService: MockAvatarService(),
                localService: MockLocalAvatarPersistence()
            )
            self.chatManager = ChatManager(service: MockChatService())
        case .development:
            self.logManager = LogManager(services: [
                ConsoleService(printParameters: false),
                FirebaseAnalyticsService(),
                MixPanelService(token: Tokens.mixPanelToken),
                FirebaseCrashlyticsService()
            ])
            
            self.authManager = AuthManager(authService: FirebaseAuthService(), logManager: logManager)
            self.userManager = UserManager(userServices: ProductionUserServices(), logManager: logManager)
            self.aiManager = AIManager(aiService: OpenAIService())
            self.avatarManager = AvatarManager(
                avatarService: FirebaseAvatarService(),
                localService: SwiftDataLocalAvatarPersistence()
            )
            self.chatManager = ChatManager(service: FirebaseChatService())
        case .production:
            self.logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                MixPanelService(token: Tokens.mixPanelToken),
                FirebaseCrashlyticsService()
            ])
            
            self.authManager = AuthManager(authService: FirebaseAuthService(), logManager: logManager)
            self.userManager = UserManager(userServices: ProductionUserServices(), logManager: logManager)
            self.aiManager = AIManager(aiService: OpenAIService())
            self.avatarManager = AvatarManager(
                avatarService: FirebaseAvatarService(),
                localService: SwiftDataLocalAvatarPersistence()
            )
            self.chatManager = ChatManager(service: FirebaseChatService())
        }
        
        pushNotificationsManager = PushNotificationsManager(logManager: logManager)
            
    }
}

extension View {
    func previewAllEnvironments(isSignIn: Bool = true) -> some View {
        self
            .environment(PushNotificationsManager())
            .environment(ChatManager(service: MockChatService()))
            .environment(AIManager(aiService: MockAIService()))
            .environment(AvatarManager(avatarService: MockAvatarService()))
            .environment(UserManager(userServices: MockUserServices(user: isSignIn ? .mock : nil)))
            .environment(AuthManager(authService: MockAuthService(authUser: isSignIn ? .mock() : nil)))
            .environment(AppState())
            .environment(LogManager(services: [ConsoleService(printParameters: false)]))
    }
}

// swiftlint:disable all
//struct EnvironmentBuilder<Content: View>: View {
//
//    @ViewBuilder let content: () -> Content
//
//    var body: some View {
//        content()
//            .environment(authManager)
//            .environment(userManager)
////            .environment(\.authService, FirebaseAuthService())
//    }
//}
// swiftlint:enable all
