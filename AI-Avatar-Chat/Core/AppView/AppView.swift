//
//  AppView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct AppView: View {
    
    @State var appState: AppState = .init()
    
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
    }
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}
