//
//  AppViewBuilder.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//
import SwiftUI

struct AppViewBuilder<TabBarView: View, OnboardingView: View>: View {
    
    var showTabBar = false
    @ViewBuilder var tabBarView: TabBarView
    @ViewBuilder var onboardingView: OnboardingView
    
    var body: some View {
        ZStack {
            if showTabBar {
                tabBarView
                    .transition(.move(edge: .trailing))
            } else {
                onboardingView
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth, value: showTabBar)
    }
}

private struct PreviewView: View {
    
    @State private var showTabBar = false
    
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
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}

#Preview {
    PreviewView()
}
