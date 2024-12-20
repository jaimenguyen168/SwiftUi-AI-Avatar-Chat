//
//  AppView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct AppView: View {
    
    @AppStorage("showTabBarView") var showTabBar = false
    
    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabBarView: {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Tab Bar")
                }
            },
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("On boarding")
                }
            }
        )
    }
}

#Preview("AppView - Onboarding") {
    AppView(showTabBar: false)
}

#Preview("AppView - Tabbar") {
    AppView(showTabBar: true)
}
