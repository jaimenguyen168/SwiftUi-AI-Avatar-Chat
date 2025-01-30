//
//  Routing.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/9/25.
//

import Foundation
import SwiftUI

enum NavigationCoreOption: Hashable {
    case chat(avatar: Avatar?, chat: Chat?)
    case category(category: Character, imageName: String)
}

extension View {
    func navigationDestinationCoreOption(option: Binding<NavigationCoreOption?>) -> some View {
        self
            .navigationDestination(item: option) { value in
                switch value {
                case .chat(let avatar, let chat):
                    if let avatar {
                        ChatView(avatar: avatar, chat: chat)
                    } else {
                        EmptyView()
                    }
                case .category(let category, let imageName):
                    CategoryListView(
                        category: category,
                        imageName: imageName
                    )
                }
            }
    }
}
