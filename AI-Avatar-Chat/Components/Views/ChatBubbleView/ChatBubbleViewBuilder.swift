//
//  ChatBubbleViewBuilder.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/4/25.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {
    
    var message: ChatMessage = .mock
    var isCurrentUser: Bool = false
    var userColor: Color = .accentColor
    var imageName: String?
    var onImagePress: (() -> Void)?
    
    var body: some View {
        ChatBubbleView(
            text: message.content?.message ?? "",
            textColor: isCurrentUser ? .white : .primary,
            backgroundColor: isCurrentUser ? userColor : Color(uiColor: .systemGray5),
            showImage: !isCurrentUser,
            imageName: imageName,
            onImagePress: onImagePress
        )
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(.leading, isCurrentUser ? 75 : 0)
        .padding(.trailing, isCurrentUser ? 0 : 75)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(
                isCurrentUser: true
            )
            ChatBubbleViewBuilder(
                message: ChatMessage(
                    id: "123",
                    chatId: "123",
                    authorId: "123",
                    content: AIChatModel(
                        role: .user,
                        content: "This is a very long message that goes multiple lines"
                    ),
                    seenByIds: nil,
                    dateCreated: Date.now
                )
            )
            ChatBubbleViewBuilder(
                message: ChatMessage(
                    id: "123",
                    chatId: "123",
                    authorId: "123",
                    content: AIChatModel(
                        role: .user,
                        content: "This is a very long message that goes multiple lines"
                    ),
                    seenByIds: nil,
                    dateCreated: Date.now
                ),
                isCurrentUser: true,
                userColor: .cyan
            )
        }
        .padding(12)
    }
}
