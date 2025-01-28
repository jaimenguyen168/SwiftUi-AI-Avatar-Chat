//
//  ChatView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/3/25.
//

import SwiftUI

struct ChatView: View {
    
    var avatar: Avatar = .mock

    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(ChatManager.self) private var chatManager
    
    @State private var currentAvatar: Avatar?
    
    @State private var chatMessages: [ChatMessage] = ChatMessage.mockConversation
    @State private var currentUser: AppUser?
    @State private var chat: Chat?
    
    @State private var showProfileModal = false
    @State private var isGeneratingResponse = false
    
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
        .onAppear {
            loadCurrentUser()
        }
    }
}

private extension ChatView {
    var chatScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == authManager.authUser?.uid
                    
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        userColor: currentUser?.profileColorSwift ?? .accent,
                        imageName: isCurrentUser ? nil : avatar.profileImageUrl,
                        onImagePress: {
                            onAvatarImagePress()
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .padding(.bottom, 4)
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
        let color: Color = userManager.currentUser?.profileColorSwift ?? .accentColor
        
        return TextField("Type your message...", text: $textMessage)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 48)
            .overlay(alignment: .trailing) {
                ZStack {
                    if isGeneratingResponse {
                        ProgressView()
                            .tint(color)
                            .padding(.trailing, 12)
                    } else {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.system(size: 32))
                            .padding(.trailing, 6)
                            .foregroundStyle(color)
                            .customButton {
                                onSendMessagePress()
                            }
                    }
                }
            }
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
    func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
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
        let content = textMessage
        
        Task {
            do {
                let uid = try authManager.getAuthId()
                let avatarId = currentAvatar?.avatarId ?? ""
                
                try TextValidationHelper.validateText(text: content)
                
                if chat == nil {
                    chat = try await createNewChat(
                        uid: uid,
                        avatarId: avatarId
                    )
                }
                
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                isGeneratingResponse = true
                
                let newMessage = AIChatModel(
                    role: .user,
                    content: content
                )
                
                let message = ChatMessage.newUserMessage(
                    chatId: chat.id,
                    userId: uid,
                    message: newMessage
                )
                
                try await chatManager.addChatMessage(
                    chatId: chat.id,
                    message: message
                )
                chatMessages.append(message)
                
                scrollToBottom()
                
                textMessage = ""
                
                let aiChats = chatMessages.compactMap({
                    $0.content
                })
                
                let response = try await aiManager.generateText(chats: aiChats)
                
                let aiMessage = ChatMessage.newAIMessage(
                    chatId: chat.id,
                    avatarId: avatarId,
                    message: response
                )
                
                try await chatManager.addChatMessage(
                    chatId: chat.id,
                    message: aiMessage
                )
                chatMessages.append(aiMessage)
                
                scrollToBottom()
            } catch {
                showAlert = AppAlert(error: error)
            }
            
            isGeneratingResponse = false
        }
    }
    
    func createNewChat(uid: String, avatarId: String) async throws -> Chat {
        let newChat = Chat.newChat(
            userId: uid,
            avatarId: avatarId
        )
        
        try await chatManager.createNewChat(chat: newChat)
        
        return newChat
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
    
    func scrollToBottom() {
        scrollPosition = chatMessages.last!.id
    }
}

// MARK: - Enum
private extension ChatView {
    enum ChatViewError: Error {
        case noChat
    }
}

#Preview("Working Chat") {
    NavigationStack {
        ChatView()
            .previewAllEnvironments()
    }
}

#Preview("Slow AI Response") {
    NavigationStack {
        ChatView()
            .environment(AIManager(aiService: MockAIService(delay: 10)))
            .previewAllEnvironments()
    }
}

#Preview("Failed Response") {
    NavigationStack {
        ChatView()
            .environment(AIManager(aiService: MockAIService(delay: 2, showError: true)))
            .previewAllEnvironments()
    }
}
