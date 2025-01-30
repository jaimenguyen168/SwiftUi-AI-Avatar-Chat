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
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }
}

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
                .background(.white)
                .customCornerRadius(12)
                .formatListRow()
                .padding(.horizontal)
            }
        } header: {
            Text(chats.isEmpty ? "" : "Chats")
        }
    }
}

private extension ChatsView {
    func loadRecentAvatars() {
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("DEBUG: failed to fetch recents with error \(error.localizedDescription)")
        }
    }
    
    func loadChats() async {
        do {
            let uid = try authManager.getAuthId()
            chats = try await chatManager
                .fetchAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            
            if chats.isEmpty {
                errorDisplayMessage = "No chats yet"
            }
        } catch {
            print("DEBUG: failed to fetch chats with error \(error.localizedDescription)")
            errorDisplayMessage = "Loading Error"
            showAlert = AppAlert(error: error)
        }
        
        isChatsLoading = false
    }
    
    func onAvatarPress(_ avatar: Avatar) {
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
