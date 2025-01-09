//
//  ChatsView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ChatsView: View {
    
    @State private var chats: [Chat] = Chat.mocks
    @State private var avatars: [Avatar] = Avatar.mocks
    @State private var option: NavigationCoreOption?
    
    var body: some View {
        NavigationStack {
            List {
                if !avatars.isEmpty {
                    recentsSection
                }
                
                chatsSection
            }
            .listStyle(.grouped)
            .navigationTitle("Chats")
            .navigationDestinationCoreOption(option: $option)
        }
    }
}

private extension ChatsView {
    var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(avatars) { avatar in
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
                Text("No chats yet")
                    .foregroundStyle(.secondary)
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .removeBgAndInsetsListRow()
            } else {
                ForEach(chats) { chat in
                    let avatar = Avatar.mocks.randomElement()!
                    ChatRowCellViewBuilder(
                        currentUserId: nil,
                        chat: chat,
                        getAvatar: {
                            try? await Task.sleep(for: .seconds(1))
                            return avatar
                        },
                        getLastChatMessage: {
                            try? await Task.sleep(for: .seconds(1))
                            return ChatMessage.mocks.randomElement()!
                        }
                    )
                    .tappableBackground()
                    .customButton(.pressable) {
                        onChatPress(chat, avatar: avatar)
                    }
                }
                .background(.white)
                .customCornerRadius(12)
                .formatListRow()
                .padding(.horizontal)
            }
        } header: {
            Text("Chats")
        }
    }
}

private extension ChatsView {
    func onAvatarPress(_ avatar: Avatar) {
        option = .chat(avatar: avatar)
    }
    
    func onChatPress(_ chat: Chat, avatar: Avatar) {
        option = .chat(avatar: avatar)
    }
}

#Preview {
    ChatsView()
        .navigationTitle(TabBarItem.chats.rawValue.capitalized)
}
