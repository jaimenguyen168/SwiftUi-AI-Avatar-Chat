//
//  ChatsView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ChatsView: View {
    
    @State private var chats: [Chat] = Chat.mocks
    
    var body: some View {
        List {
            ForEach(chats) { chat in
                Text(chat.dateModified.description)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatsView()
            .navigationTitle(TabBarItem.chats.rawValue.capitalized)
    }
}
