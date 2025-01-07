//
//  ChatsView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ChatsView: View {
    
    @State private var chats: [Chat] = Chat.mocks
    @State private var selectedChat: Chat?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: nil,
                        chat: chat,
                        getAvatar: {
                            try? await Task.sleep(for: .seconds(1))
                            return Avatar.mock
                        },
                        getLastChatMessage: {
                            try? await Task.sleep(for: .seconds(1))
                            return ChatMessage.mock
                        }
                    )
                    .customButton(.pressable) {
                        selectedChat = chat
                    }
                    .listRowInsets(EdgeInsets(.zero))
                }
            }
            .navigationTitle("Chats")
            .navigationDestination(item: $selectedChat) { _ in
                ChatView()
            }
        }
    }
}

#Preview {
    ChatsView()
        .navigationTitle(TabBarItem.chats.rawValue.capitalized)
}
