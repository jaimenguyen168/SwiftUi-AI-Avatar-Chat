//
//  CategoryListView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/7/25.
//

import SwiftUI

struct CategoryListView: View {
    
    var category: Character = .default
    var imageName = Constants.randomImageUrl
    @State private var avatars: [Avatar] = Avatar.mocks
    @State private var option: NavigationCoreOption?
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageUrl: imageName,
                font: .title,
                cornerRadius: 0
            )
            .removeBgAndInsetsListRow()
            
            ForEach(avatars) { avatar in
                CustomListCellView(
                    title: avatar.name,
                    subtitle: avatar.description,
                    imageUrl: avatar.profileImageUrl
                )
                .customButton {
                    onAvatarPress(avatar)
                }
            }
            .removeBgAndInsetsListRow()
            .padding(6)
        }
        .ignoresSafeArea()
        .listStyle(.plain)
        .navigationDestinationCoreOption(option: $option)
    }
}

private extension CategoryListView {
    func onAvatarPress(_ avatar: Avatar) {
        option = .chat(avatar: avatar)
    }
}

#Preview {
    NavigationStack {
        CategoryListView()
    }
}
