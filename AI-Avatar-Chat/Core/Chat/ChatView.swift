//
//  ChatView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/3/25.
//

import SwiftUI

struct ChatView: View {
    
    @State private var chatMessages: [ChatMessage] = ChatMessage.mockConversation
    @State private var avatar: Avatar? = .mock
    @State private var currentUser: User? = .mock
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(chatMessages) { message in
                        let isCurrentUser = message.authorId == currentUser?.userId
                        
                        ChatBubbleViewBuilder(
                            message: message,
                            isCurrentUser: isCurrentUser,
                            imageName: isCurrentUser ? nil : avatar?.profileImageUrl
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(8)
            }
            
            Rectangle()
                .frame(height: 50)
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
