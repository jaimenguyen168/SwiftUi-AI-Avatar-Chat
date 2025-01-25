//
//  ProfileView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var showSettingsView: Bool = false
    @State private var showCreateAvatarView: Bool = false
    @State private var currentUser: AppUser?
    @State private var myAvatars: [Avatar] = []
    @State private var isLoading: Bool = true
    @State private var showAlert: AppAlert?
    
    @State private var option: NavigationCoreOption?
    
    var body: some View {
        NavigationStack {
            List {
                currentUserInfoSection
                
                myAvatarSection
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingButton
                }
            }
            .navigationDestinationCoreOption(option: $option)
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(
            isPresented: $showCreateAvatarView,
            onDismiss: {
                Task { await loadData() }
            },
            content: {
            CreateAvatarView()
        })
        .task {
            await loadData()
        }
        .showCustomAlert(alert: $showAlert)
    }
}

// MARK: Views Section
private extension ProfileView {
    var currentUserInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(currentUser?.profileColorSwift ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }
    
    var myAvatarSection: some View {
        Section {
            if myAvatars.isEmpty {
                ZStack {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundStyle(.secondary)
                .listRowBackground(Color.clear)
            } else {
                ForEach(myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        title: avatar.name,
                        subtitle: nil,
                        imageUrl: avatar.profileImageUrl
                    )
                    .customButton(.highlight(cornerRadius: 12)) {
                        onAvatarPress(avatar)
                    }
                    .formatListRow()
                }
                .onDelete { indexSet in
                    onDeleteAvatar(indexSet: indexSet)
                }
            }
        } header: {
            HStack(spacing: 0) {
                Text("My Avatars")
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .customButton {
                        onNewAvatarButtonTap()
                    }
            }
        }
    }
    
    var settingButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .customButton {
                onSettingsButtonTap()
            }
    }
}

// MARK: Logic Section
private extension ProfileView {
    func loadData() async {
        self.currentUser = userManager.currentUser
        
        do {
            let uid = currentUser?.userId ?? ""
            myAvatars = try await avatarManager.getAvatarsForAuthor(authorId: uid)
        } catch {
            print("DEBUG: Failed to load avatars for profile with error \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func onNewAvatarButtonTap() {
        showCreateAvatarView = true
    }
    
    func onSettingsButtonTap() {
        showSettingsView = true
    }
    
    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatarToDelete = myAvatars[index]
        
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarToDelete.avatarId)
                myAvatars.remove(at: index)
            } catch {
                showAlert = AppAlert(
                    title: "Unable to delete",
                    subtitle: "Please try again later"
                )
            }
        }
    }
    
    func onAvatarPress(_ avatar: Avatar) {
        option = .chat(avatar: avatar)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .previewAllEnvironments()
    }
}
