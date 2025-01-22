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
            coverSection
            
            if isLoading {
                progressView
            } else if avatars.isEmpty {
                noAvatarsSection
                    .padding(40)
            } else {
                avatarsSection
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

// MARK: Views Section
private extension CategoryListView {
    var coverSection: some View {
        CategoryCellView(
            title: category.plural.capitalized,
            imageUrl: imageName,
            font: .title,
            cornerRadius: 0
        )
        .removeBgAndInsetsListRow()
    }
    
    var progressView: some View {
        ProgressView()
            .scaleEffect(1.2)
            .formatListRow()
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .tint(.accent)
    }
    
    var avatarsSection: some View {
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
    }
    
    var noAvatarsSection: some View {
        Text("No Avatars Found 😭")
            .formatListRow()
            .frame(maxWidth: .infinity, alignment: .center)
            .foregroundStyle(.secondary)
    }
}

// MARK: Logic Section
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

#Preview("No Data") {
    NavigationStack {
        CategoryListView()
            .environment(
                AvatarManager(
                    avatarService: MockAvatarService(
                        avatars: []
                    )
                )
            )
    }
}

#Preview("Has Data") {
    NavigationStack {
        CategoryListView()
            .environment(
                AvatarManager(
                    avatarService: MockAvatarService()
                )
            )
    }
}

#Preview("Slow Loading") {
    NavigationStack {
        CategoryListView()
            .environment(
                AvatarManager(
                    avatarService: MockAvatarService(
                        delay: 5.0
                    )
                )
            )
    }
}

#Preview("Error Loading") {
    NavigationStack {
        CategoryListView()
            .environment(
                AvatarManager(
                    avatarService: MockAvatarService(
                        delay: 2.0,
                        showError: true
                    )
                )
            )
    }
}
