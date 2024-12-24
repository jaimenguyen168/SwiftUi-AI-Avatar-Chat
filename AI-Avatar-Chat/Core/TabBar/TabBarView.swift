//
//  TabBarView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

enum TabBarItem: String {
    case explore, chats, profile
}

struct TabBarView: View {
    
    @State private var selectedTab: TabBarItem = .explore
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
                .tag(TabBarItem.explore)
            
            ChatsView()
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(TabBarItem.chats)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(TabBarItem.profile)
        }
    }
}

#Preview {
    TabBarView()
}
