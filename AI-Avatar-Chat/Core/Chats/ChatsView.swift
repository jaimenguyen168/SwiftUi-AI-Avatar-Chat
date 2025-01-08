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
                            return Avatar.mocks.randomElement()!
                        },
                        getLastChatMessage: {
                            try? await Task.sleep(for: .seconds(1))
                            return ChatMessage.mocks.randomElement()!
                        }
                    )
                    .customButton(.pressable) {
                        onChatPress(chat)
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

private extension ChatsView {
    func onChatPress(_ chat: Chat) {
        selectedChat = chat
    }
}

#Preview {
    ChatsView()
        .navigationTitle(TabBarItem.chats.rawValue.capitalized)
}
