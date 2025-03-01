//
//  ChatView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/3/25.
//

import SwiftUI

struct ChatView: View {
    
    var avatar: Avatar
    @State var chat: Chat?
    
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentAvatar: Avatar?
    
    @State private var chatMessages: [ChatMessage] = []
    @State private var currentUser: AppUser?
    
    @State private var showProfileModal = false
    @State private var isGeneratingResponse = false
    
    @State private var textMessage = ""
    @State private var scrollPosition: String?
    
    @State private var showChatSettings: AppAlert?
    @State private var showAlert: AppAlert?
    
    @State private var hasAppeared = false
    
    var body: some View {
        VStack(spacing: 0) {
            chatScrollView
            
            sendMessageSection
        }
        .navigationTitle(avatar.name ?? "Avatar")
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
        .task {
            await loadChat()
            await listenForChatMessages()
            hasAppeared = true
        }
        .onAppear {
            loadCurrentUser()
        }
        .screenAppearAnalytics(name: "ChatView")
    }
}

// MARK: Views Section
private extension ChatView {
    var chatScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == currentUser?.userId
                    
                    if chatIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        userColor: currentUser?.profileColorSwift ?? .accent,
                        imageName: isCurrentUser ? nil : avatar.profileImageUrl,
                        onImagePress: {
                            onAvatarImagePress()
                        }
                    )
                    .padding(.bottom, chatMessages.last?.id == message.id ? 16 : 0)
                    .onAppear {
                        onMessageDidappear(message: message)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
        .scrollTargetLayout()
        .defaultScrollAnchor(.bottom)
        .scrollPosition(id: $scrollPosition, anchor: .bottom)
        .animation(.default, value: scrollPosition)
        .animation(hasAppeared ? .default : .easeIn, value: chatMessages.count)
        .onChange(of: chatMessages.count) { _, _ in
            scrollToBottom()
        }
    }
    
    func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
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

// MARK: Additional Data Section
private extension ChatView {
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatar: Avatar?)
        case loadAvatarFailed(error: Error)
        case loadChatStart
        case loadChatSuccess(chat: Chat?)
        case loadChatFailed(error: Error)
        case loadMessagesStart
        case loadMessagedFailed(error: Error)
        case messageSeenFailed(error: Error)
        case sendMessageStart(chat: Chat?, avatar: Avatar?)
        case sendMessageFailed(error: Error)
        case sendMessageSent(chat: Chat?, avatar: Avatar?, message: ChatMessage)
        case sendMessageResponse(chat: Chat?, avatar: Avatar?, message: ChatMessage)
        case sendMessageResponseSent(chat: Chat?, avatar: Avatar?, message: ChatMessage)
        case createChatStart
        case chatSettingsPressed
        case reportChatStart
        case reportChatSuccess
        case reportChatFailed(error: Error)
        case deleteChatStart
        case deleteChatSuccess
        case deleteChatFailed(error: Error)
        case avatarImagePressed(avatar: Avatar?)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart:          "ChatView_LoadAvatar_Start"
            case .loadAvatarSuccess:        "ChatView_LoadAvatar_Success"
            case .loadAvatarFailed:         "ChatView_LoadAvatar_Failed"
            case .loadChatStart:            "ChatView_LoadChat_Start"
            case .loadChatSuccess:          "ChatView_LoadChat_Success"
            case .loadChatFailed:           "ChatView_LoadChat_Failed"
            case .loadMessagesStart:        "ChatView_LoadMessages_Start"
            case .loadMessagedFailed:       "ChatView_LoadMessages_Failed"
            case .messageSeenFailed:        "ChatView_MessageSeen_Failed"
            case .sendMessageStart:         "ChatView_SendMessage_Start"
            case .sendMessageFailed:        "ChatView_SendMessage_Failed"
            case .sendMessageSent:          "ChatView_SendMessage_Sent"
            case .sendMessageResponse:      "ChatView_SendMessage_Response"
            case .sendMessageResponseSent:  "ChatView_SendMessage_ResponseSent"
            case .createChatStart:          "ChatView_CreateChat_Start"
            case .chatSettingsPressed:      "ChatView_ChatSettings_Pressed"
            case .reportChatStart:          "ChatView_ReportChat_Start"
            case .reportChatSuccess:        "ChatView_ReportChat_Success"
            case .reportChatFailed:         "ChatView_ReportChat_Failed"
            case .deleteChatStart:          "ChatView_DeleteChat_Start"
            case .deleteChatSuccess:        "ChatView_DeleteChat_Success"
            case .deleteChatFailed:         "ChatView_DeleteChat_Failed"
            case .avatarImagePressed:       "ChatView_AvatarImage_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarSuccess(avatar: let avatar), .avatarImagePressed(avatar: let avatar):
                return avatar?.eventParameters
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
            case .loadAvatarFailed(error: let error),
                    .loadChatFailed(error: let error),
                    .loadMessagedFailed(error: let error),
                    .messageSeenFailed(error: let error),
                    .sendMessageFailed(error: let error),
                    .reportChatFailed(error: let error),
                    .deleteChatFailed(error: let error):
                return error.eventParameters
            case .sendMessageStart(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                return dict
            case .sendMessageSent(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                dict.merge(message.eventParameters)
                return dict
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .loadAvatarFailed, .messageSeenFailed, .reportChatFailed, .deleteChatFailed: .severe
            case .loadChatFailed, .sendMessageFailed, .loadMessagedFailed: .warning
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension ChatView {
    func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    // may not needed since we pass in avatar
    func loadAvatar() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        
        do {
            currentAvatar = try await avatarManager.getAvatarById(avatar.avatarId)
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatar: currentAvatar))
            
            try? await avatarManager.addRecentAvatar(avatar)
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFailed(error: error))
        }
    }
    
    func loadChat() async {
        logManager.trackEvent(event: Event.loadChatStart)
        
        do {
            let uid = try authManager.getAuthId()
            chat = try await chatManager.fetchChat(
                userId: uid,
                avatarId: avatar.avatarId
            )
            
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager.trackEvent(event: Event.loadChatFailed(error: error))
        }
    }
    
    func onMessageDidappear(message: ChatMessage) {
        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = message.chatId
                
                guard !message.hasBeenSeenByCurrentUser(userId: uid) else { return }
                
                try await chatManager
                    .markChatMessageAsSeen(
                        chatId: chatId,
                        messageId: message.id,
                        userId: uid
                    )
            } catch {
                logManager.trackEvent(event: Event.messageSeenFailed(error: error))
            }
        }
    }
    
    func listenForChatMessages() async {
        logManager.trackEvent(event: Event.loadMessagesStart)
        
        do {
            guard let chat else { throw ChatViewError.noChat }
            let chatId = chat.id
            
            for try await value in chatManager.streamChatMessages(chatId: chatId) {
                
                chatMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated, ascending: true)
            }
        } catch {
            logManager.trackEvent(event: Event.loadMessagedFailed(error: error))
        }

    }
    
    // swiftlint:disable function_body_length
    func onSendMessagePress() {
        let content = textMessage
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: currentAvatar))
        
        Task {
            do {
                let uid = currentUser?.userId ?? ""
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
                
                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: currentAvatar, message: message))

                textMessage = ""
                
                var aiChats = chatMessages.compactMap({
                    $0.content
                })
                
                let systemMessage = AIChatModel(
                    role: .system,
                    content: Avatar.aiDescription(avatar)
                )
                aiChats.insert(systemMessage, at: 0)
                
                let response = try await aiManager.generateText(chats: aiChats)
                
                let aiMessage = ChatMessage.newAIMessage(
                    chatId: chat.id,
                    avatarId: avatarId,
                    message: response
                )
                
                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: currentAvatar, message: aiMessage))
                
                try await chatManager.addChatMessage(
                    chatId: chat.id,
                    message: aiMessage
                )
                
                logManager.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: currentAvatar, message: aiMessage))
            } catch {
                showAlert = AppAlert(error: error)
                logManager.trackEvent(event: Event.sendMessageFailed(error: error))
            }
            
            isGeneratingResponse = false
        }
    }
    // swiftlint:enable function_body_length
    
    func createNewChat(uid: String, avatarId: String) async throws -> Chat {
        logManager.trackEvent(event: Event.createChatStart)
        let newChat = Chat.newChat(
            userId: uid,
            avatarId: avatarId
        )
        
        try await chatManager.createNewChat(chat: newChat)
        
        // force to attach listener when no chat yet
        defer {
            Task {
                await listenForChatMessages()
            }
        }
        
        return newChat
    }
    
    func onChatSettingPress() {
        logManager.trackEvent(event: Event.chatSettingsPressed)
        showChatSettings = AppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button(
                            "Report User / Chat",
                            role: .destructive
                        ) {
                            onReportChatPress()
                        }
                        Button(
                            "Delete Chat",
                            role: .destructive
                        ) {
                            onDeleteChatPress()
                        }
                    }
                )
            }
        )
    }
    
    func onDeleteChatPress() {
        logManager.trackEvent(event: Event.deleteChatStart)
        
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                logManager.trackEvent(event: Event.reportChatSuccess)
                
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.reportChatFailed(error: error))
                
                showAlert = .init(
                    title: "Something went wrong!",
                    subtitle: "Please try again later."
                )
            }
        }
    }
    
    func onReportChatPress() {
        logManager.trackEvent(event: Event.reportChatStart)
        
        Task {
            do {
                let chatId = try getChatId()
                let uid = try authManager.getAuthId()
                try await chatManager.reportChat(chatId: chatId, userId: uid)
                logManager.trackEvent(event: Event.reportChatSuccess)
                
                showAlert = .init(
                    title: "Reported!",
                    subtitle: "Your report has been sent successfully. We will look into this matter. Thank you!"
                )
            } catch {
                logManager.trackEvent(event: Event.reportChatFailed(error: error))
                
                showAlert = .init(
                    title: "Something went wrong!",
                    subtitle: "Please try again later."
                )
            }
        }
    }
    
    func onAvatarImagePress() {
        logManager.trackEvent(event: Event.avatarImagePressed(avatar: currentAvatar))
        
        showProfileModal = true
    }
    
    func scrollToBottom() {
        if hasAppeared {
            withAnimation(.default) {
                scrollPosition = chatMessages.last?.id
            }
        } else {
            scrollPosition = chatMessages.last?.id
        }
    }
    
    func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        return chat.id
    }
    
    func chatIsDelayed(message: ChatMessage) -> Bool {
        let currentMessageDate = message.dateCreatedCalculated
        
        guard let index = chatMessages.firstIndex(
            where: {
                $0.id == message.id
            }), chatMessages.indices.contains(
                index - 1
            ) else {
            return false
        }
        
        let previousMessageDate = chatMessages[index - 1].dateCreatedCalculated
        let timeDiff = currentMessageDate.timeIntervalSince(previousMessageDate)
        
        let threshold: TimeInterval = 60 * 45 // 45 minutes
        
        return timeDiff > threshold
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
        ChatView(avatar: .mock)
            .previewAllEnvironments()
    }
}

#Preview("Slow AI Response") {
    NavigationStack {
        ChatView(avatar: .mock)
            .environment(AIManager(aiService: MockAIService(delay: 10)))
            .previewAllEnvironments()
    }
}

#Preview("Failed Response") {
    NavigationStack {
        ChatView(avatar: .mock)
            .environment(AIManager(aiService: MockAIService(delay: 2, showError: true)))
            .previewAllEnvironments()
    }
}
