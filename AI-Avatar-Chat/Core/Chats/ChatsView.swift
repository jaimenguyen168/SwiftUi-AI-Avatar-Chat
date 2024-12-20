//
//  ChatsView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ChatsView: View {
    var body: some View {
        Text("Hello, Chats!")
    }
}

#Preview {
    NavigationStack {
        ChatsView()
            .navigationTitle(TabBarItem.chats.rawValue.capitalized)
    }
}
