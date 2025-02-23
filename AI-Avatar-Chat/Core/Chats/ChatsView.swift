//
//  ChatsView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ChatsView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    
    @Environment(LogManager.self) private var logManager
    
    @State private var chats: [Chat] = []
    @State private var recentAvatars: [Avatar] = []
    @State private var option: NavigationCoreOption?
    @State private var isChatsLoading = true
    
    @State private var showAlert: AppAlert?
    
    @State private var errorDisplayMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                
                if isChatsLoading {
                    ProgressView()
                        .padding(40)
                        .frame(maxWidth: .infinity)
                        .tint(.accent)
                        .formatListRow()
                } else {
                    chatsSection
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Chats")
            .navigationDestinationCoreOption(option: $option)
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "ChatsView")
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
}

// MARK: Views Section
private extension ChatsView {
    var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars) { avatar in
                        VStack(spacing: 8) {
                            ZStack {
                                if let imagename = avatar.profileImageUrl {
                                    ImageLoaderView(urlString: imagename)
                                } else {
                                    Rectangle()
                                        .fill(.secondary)
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(Circle())
                            .padding(.vertical, 4)
                            .padding(.trailing, 6)
                            
                            Text(avatar.name ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .customButton {
                            onAvatarPress(avatar)
                        }
                        .offset(x: 20)
                    }
                }
            }
            .frame(height: 120)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .formatListRow()
        } header: {
            Text("Recents")
        }
    }
    
    var chatsSection: some View {
        Section {
            if chats.isEmpty {
                Text(errorDisplayMessage)
                    .formatListRow()
                    .foregroundStyle(.secondary)
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 36)
            } else {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: authManager.authUser?.uid,
                        chat: chat,
                        getAvatar: {
                            try? await avatarManager.getAvatarById(chat.avatarId)
                        },
                        getLastChatMessage: {
                            try? await chatManager.getLastChatMessage(chatId: chat.id)
                        }
                    )
                }
                .background(Color(.systemBackground))
                .customCornerRadius(12)
                .formatListRow()
                .padding(.horizontal)
            }
        } header: {
            Text(chats.isEmpty ? "" : "Chats")
        }
    }
}

// MARK: Additional Data Section
private extension ChatsView {
    enum Event: LoggableEvent {
        case loadRecentAvatarsStart
        case loadRecentAvatarsSuccess(avatarCount: Int)
        case loadRecentAvatarsFailed(error: Error)
        case loadChatsStart
        case loadChatsSuccess(chatCount: Int)
        case loadChatsFailed(error: Error)
        case avatarPressed(avatar: Avatar?)
        
        var eventName: String {
            switch self {
            case .loadRecentAvatarsStart:       "ChatsView_LoadRecentAvatars_Start"
            case .loadRecentAvatarsSuccess:     "ChatsView_LoadRecentAvatars_Success"
            case .loadRecentAvatarsFailed:      "ChatsView_LoadRecentAvatars_Failed"
            case .loadChatsStart:               "ChatsView_LoadChats_Start"
            case .loadChatsSuccess:             "ChatsView_LoadChats_Success"
            case .loadChatsFailed:              "ChatsView_LoadChats_Failed"
            case .avatarPressed:                "ChatsView_AvatarPressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadChatsFailed(error: let error), .loadRecentAvatarsFailed(error: let error):
                return error.eventParameters
            case .loadRecentAvatarsSuccess(avatarCount: let count):
                return ["avatars_count": count]
            case .loadChatsSuccess(chatCount: let count):
                return ["chats_count": count]
            case .avatarPressed(avatar: let avatar):
                return avatar?.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .loadChatsFailed, .loadRecentAvatarsFailed: .severe
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension ChatsView {
    func loadRecentAvatars() {
        logManager.trackEvent(event: Event.loadRecentAvatarsStart)
        
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadRecentAvatarsSuccess(avatarCount: recentAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadRecentAvatarsFailed(error: error))
        }
    }
    
    func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        
        do {
            let uid = authManager.authUser?.uid ?? ""
            chats = try await chatManager
                .fetchAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            
            logManager.trackEvent(event: Event.loadChatsSuccess(chatCount: chats.count))
            
            if chats.isEmpty {
                errorDisplayMessage = "No chats yet"
            }
        } catch {
            logManager.trackEvent(event: Event.loadChatsFailed(error: error))
            errorDisplayMessage = "Loading Error"
            showAlert = AppAlert(error: error)
        }
        
        isChatsLoading = false
    }
    
    func onAvatarPress(_ avatar: Avatar) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        option = .chat(avatar: avatar, chat: nil)
    }
}

#Preview("Has Data") {
    ChatsView()
        .previewAllEnvironments()
}

#Preview("No Data") {
    ChatsView()
        .environment(AvatarManager(
            avatarService: MockAvatarService(avatars: []),
            localService: MockLocalAvatarPersistence(avatars: [])))
        .environment(ChatManager(service: MockChatService(chats: [])))
        .previewAllEnvironments()
}

#Preview("Slow Loading") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5)))
        .previewAllEnvironments()
}

#Preview("Error") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(showError: true)))
        .previewAllEnvironments()
}
