//
//  CategoryListView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/7/25.
//

import SwiftUI

struct CategoryListView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    var category: Character = .default
    var imageName = Constants.randomImageUrl
    @State private var avatars: [Avatar] = []
    @State private var isLoading = true
    
    @State private var option: NavigationCoreOption?
    
    @State private var showAlert: AppAlert?
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageUrl: imageName,
                font: .title,
                cornerRadius: 0
            )
            .removeBgAndInsetsListRow()
            
            if avatars.isEmpty && isLoading {
                ProgressView()
                    .formatListRow()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            } else {
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
        }
        .ignoresSafeArea()
        .listStyle(.plain)
        .navigationDestinationCoreOption(option: $option)
        .task {
            await loadAvatars()
        }
        .showCustomAlert(alert: $showAlert)
    }
}

private extension CategoryListView {
    func loadAvatars() async {
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
        } catch {
            showAlert = AppAlert(error: error)
        }
        
        isLoading = false
    }
    
    func onAvatarPress(_ avatar: Avatar) {
        option = .chat(avatar: avatar)
    }
}

#Preview {
    NavigationStack {
        CategoryListView()
            .environment(AvatarManager(avatarService: MockAvatarService()))
    }
}
