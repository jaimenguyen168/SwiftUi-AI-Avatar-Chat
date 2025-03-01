//
//  ChatRowCellViewBuilder.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/23/24.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var currentUserId: String? = ""
    var chat: Chat = .mock
    var getAvatar: () async -> Avatar?
    var getLastChatMessage: () async -> ChatMessage?
    
    @State private var avatar: Avatar?
    @State private var lastChatMessage: ChatMessage?
    @State private var option: NavigationCoreOption?
    
    @State private var didLoadAvatar = false
    @State private var didLoadLastChatMessage = false
    
    private var isLoading: Bool {
        !(didLoadAvatar && didLoadLastChatMessage)
    }
    
    private var hasNewMessage: Bool {
        guard let lastChatMessage, let currentUserId else { return false }
        return !lastChatMessage.hasBeenSeenByCurrentUser(userId: currentUserId)
    }
    
    private var subheadline: String? {
        if isLoading {
            return "xxxx xxxx xxxx xxxx"
        }
        
        if avatar == nil && lastChatMessage == nil {
            return "Error"
        }
        
        return lastChatMessage?.content?.message
    }
    
    var body: some View {
        ChatRowCellView(
            imageUrl: avatar?.profileImageUrl,
            headline: isLoading ? "xxxx xxxx" : avatar?.name,
            subheadline: subheadline,
            hasNewMessage: isLoading ? false : hasNewMessage
        )
        .background(colorScheme.backgroundPrimary)
        .tappableBackground()
        .customButton(.pressable) {
            onChatPress(chat, avatar: avatar)
        }
        .navigationDestinationCoreOption(option: $option)
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task {
            lastChatMessage = await getLastChatMessage()
            didLoadLastChatMessage = true
        }
    }
    
    private func onChatPress(_ chat: Chat, avatar: Avatar?) {
        option = .chat(avatar: avatar, chat: chat)
    }
}

#Preview {
    VStack {
        ChatRowCellViewBuilder(
            chat: .mock,
            getAvatar: {
                try? await Task.sleep(for: .seconds(2))
                return .mock
            },
            getLastChatMessage: {
                try? await Task.sleep(for: .seconds(2))
                return .mock
            }
        )
        
        ChatRowCellViewBuilder(
            chat: .mock,
            getAvatar: {
                try? await Task.sleep(for: .seconds(4))
                return Avatar.mock
            },
            getLastChatMessage: {
                try? await Task.sleep(for: .seconds(4))
                return ChatMessage.mock
            }
        )
        
        ChatRowCellViewBuilder(
            chat: .mock,
            getAvatar: {
                try? await Task.sleep(for: .seconds(2))
                return Avatar.mock
            },
            getLastChatMessage: {
                try? await Task.sleep(for: .seconds(3))
                return ChatMessage.mock
            }
        )
        
        ChatRowCellViewBuilder(
            chat: .mock,
            getAvatar: {
                nil
            },
            getLastChatMessage: {
                nil
            }
        )
    }
}
