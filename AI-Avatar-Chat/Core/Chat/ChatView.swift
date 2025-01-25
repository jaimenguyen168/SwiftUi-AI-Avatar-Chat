//
//  ChatView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/3/25.
//

import SwiftUI

struct ChatView: View {
    
    var avatar: Avatar = .mock
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    
    @State private var currentAvatar: Avatar?
    
    @State private var chatMessages: [ChatMessage] = ChatMessage.mockConversation
    @State private var currentUser: AppUser? = .mock
    
    @State private var showProfileModal = false
    
    @State private var textMessage = ""
    @State private var scrollPosition: String?
    
    @State private var showChatSettings: AppAlert?
    @State private var showAlert: AppAlert?
    
    var body: some View {
        VStack(spacing: 0) {
            chatScrollView
            
            sendMessageSection
        }
        .navigationTitle(avatar.name ?? "")
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
        .toolbar(.hidden, for: .tabBar)
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            profileModal(avatar: avatar)
        }
        .task {
            await loadAvatar()
        }
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
                        imageName: isCurrentUser ? nil : avatar.profileImageUrl,
                        onImagePress: {
                            onAvatarImagePress()
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
        .defaultScrollAnchor(.bottom)
        .scrollPosition(id: $scrollPosition, anchor: .bottom)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
        .onAppear {
            withAnimation(.default) {
                scrollPosition = chatMessages.last?.id
            }
        }
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
    
    func profileModal(avatar: Avatar) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageUrl,
            title: avatar.name,
            subtitle: avatar.character?.rawValue.capitalized,
            headline: avatar.description,
            onXmarkPress: {
                showProfileModal = false
            }
        )
        .padding(40)
        .transition(.move(edge: .leading))
    }
}

private extension ChatView {
    // may not needed
    func loadAvatar() async {
        do {
            currentAvatar = try await avatarManager.getAvatarById(avatar.avatarId)
            
            try? await avatarManager.addRecentAvatar(avatar)
        } catch {
            print("DEBUG: failed to load avatar for chat with error \(error.localizedDescription)")
        }
    }
    
    func onSendMessagePress() {
        guard let currentUser else { return }
        
        let content = textMessage
        
        Task {
            do {
                try TextValidationHelper.validateText(text: content)
                
                let newMessage = AIChatModel(
                    role: .user,
                    content: content
                )
                
                let message = ChatMessage(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: currentUser.userId,
                    content: newMessage,
                    seenByIds: nil,
                    dateCreated: .now
                )
                
                chatMessages.append(message)
                
                scrollPosition = message.id
                
                textMessage = ""
                
                let aiChats = chatMessages.compactMap({
                    $0.content
                })
                
                let response = try await aiManager.generateText(chats: aiChats)
                
                let aiMessage = ChatMessage(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: avatar.id,
                    content: response,
                    seenByIds: nil,
                    dateCreated: .now
                )
                
                chatMessages.append(aiMessage)
            } catch {
                showAlert = AppAlert(error: error)
            }
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
    
    func onAvatarImagePress() {
        showProfileModal = true
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environment(AvatarManager(avatarService: MockAvatarService()))
            .environment(AIManager(aiService: OpenAIService()))
    }
}
