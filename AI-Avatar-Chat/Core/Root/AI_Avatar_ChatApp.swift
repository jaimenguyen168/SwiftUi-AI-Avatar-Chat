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
        
        dependencies = Dependency()

    return true
  }
}

@MainActor
struct Dependency {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    
    init() {
        self.authManager = AuthManager(
            authService: FirebaseAuthService()
        )
        self.userManager = UserManager(
            userServices: ProductionUserServices()
        )
        self.aiManager = AIManager(
            aiService: OpenAIService()
        )
        self.avatarManager = AvatarManager(
            avatarService: FirebaseAvatarService(),
            localService: SwiftDataLocalAvatarPersistence()
        )
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
