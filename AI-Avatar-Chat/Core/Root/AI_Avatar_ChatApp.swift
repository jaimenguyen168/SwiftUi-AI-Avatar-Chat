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
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.authManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var dependencies: Dependency!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp
            .configure()
        
        #if MOCK
        // MARK: - Mock Dependency Scheme
        dependencies = Dependency(.mock(isSignedIn: true))
        
        #elseif DEV
        // MARK: - Production Dependency Scheme + Extra Dev Tools
        dependencies = Dependency(.development)
        
        #else
        // MARK: - Production Dependency Scheme
        dependencies = Dependency(.production)
        
        #endif

    return true
  }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), development, production
}

@MainActor
struct Dependency {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    
    init(_ config: BuildConfiguration) {
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            self.authManager = AuthManager(authService: MockAuthService(
                authUser: isSignedIn ? .mock() : nil))
            self.userManager = UserManager(userServices: MockUserServices(
                user: isSignedIn ? .mock : nil))
            self.aiManager = AIManager(aiService: MockAIService(delay: 2))
            self.avatarManager = AvatarManager(
                avatarService: MockAvatarService(),
                localService: MockLocalAvatarPersistence()
            )
            self.chatManager = ChatManager(service: MockChatService())
        case .development:
            self.authManager = AuthManager(authService: FirebaseAuthService())
            self.userManager = UserManager(userServices: ProductionUserServices())
            self.aiManager = AIManager(aiService: OpenAIService())
            self.avatarManager = AvatarManager(
                avatarService: FirebaseAvatarService(),
                localService: SwiftDataLocalAvatarPersistence()
            )
            self.chatManager = ChatManager(service: FirebaseChatService())
        case .production:
            self.authManager = AuthManager(authService: FirebaseAuthService())
            self.userManager = UserManager(userServices: ProductionUserServices())
            self.aiManager = AIManager(aiService: OpenAIService())
            self.avatarManager = AvatarManager(
                avatarService: FirebaseAvatarService(),
                localService: SwiftDataLocalAvatarPersistence()
            )
            self.chatManager = ChatManager(service: FirebaseChatService())
            print("production is running...")
        }
    }
}

extension View {
    func previewAllEnvironments(isSignIn: Bool = true) -> some View {
        self
            .environment(ChatManager(service: MockChatService()))
            .environment(AIManager(aiService: MockAIService()))
            .environment(AvatarManager(avatarService: MockAvatarService()))
            .environment(UserManager(userServices: MockUserServices(user: isSignIn ? .mock : nil)))
            .environment(AuthManager(authService: MockAuthService(authUser: isSignIn ? .mock() : nil)))
            .environment(AppState())
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
