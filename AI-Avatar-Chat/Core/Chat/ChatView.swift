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
    
    @State private var textMessage = ""
    @State private var scrollPosition: String?
    
    @State private var showChatSettings: AppAlert?
    @State private var showAlert: AppAlert?
    
    var body: some View {
        VStack(spacing: 0) {
            chatScrollView
            
            sendMessageSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.accent)
                    .padding(8)
                    .tappableBackground()
                    .customButton {
                        onChatSettingPress()
                    }
            }
        }
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
    }
}

private extension ChatView {
    var chatScrollView: some View {
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
        .defaultScrollAnchor(.bottom)
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
    }
    
    var sendMessageSection: some View {
        TextField("Type your message...", text: $textMessage)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 48)
            .overlay(
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 6)
                    .foregroundStyle(.accent)
                    .customButton {
                        onSendMessagePress()
                    }
                , alignment: .trailing
            )
            .background(
                ZStack(alignment: .trailing) {
                    Capsule()
                        .fill(Color(uiColor: .systemBackground))
                    
                    Capsule()
                        .stroke(.gray.opacity(0.5), lineWidth: 1)
                }
            )
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }
}

private extension ChatView {
    func onSendMessagePress() {
        guard let currentUser else { return }
        
        do {
            try TextValidationHelper.validateText(text: textMessage)
            
            let message = ChatMessage(
                id: UUID().uuidString,
                chatId: UUID().uuidString,
                authorId: currentUser.userId,
                content: textMessage,
                seenByIds: nil,
                dateCreated: .now
            )
            
            chatMessages.append(message)
            
            scrollPosition = message.id
            
            textMessage = ""
        } catch {
            showAlert = AppAlert(error: error)
        }
    }
    
    func onChatSettingPress() {
        showChatSettings = AppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {}
                        Button("Delete Chat", role: .destructive) {}
                    }
                )
            }
        )
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
