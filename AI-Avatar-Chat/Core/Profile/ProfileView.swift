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
    
    @Environment(LogManager.self) private var logManager
    
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
        .screenAppearAnalytics(name: "ProfileView")
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
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

// MARK: Additional Data Section
private extension ProfileView {
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess(avatarCount: Int)
        case loadAvatarsFailed(error: Error)
        case newAvatarPressed
        case settingsPressed
        case avatatPressed(avatar: Avatar)
        case deleteAvatarStart(avatar: Avatar)
        case deleteAvatarSuccess(avatar: Avatar)
        case deleteAvatarFailed(error: Error)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:     "ProfileView_LoadAvatars_Start"
            case .loadAvatarsSuccess:   "ProfileView_LoadAvatars_Success"
            case .loadAvatarsFailed:    "ProfileView_LoadAvatars_Failed"
            case .newAvatarPressed:     "ProfileView_NewAvatar_Pressed"
            case .settingsPressed:      "ProfileView_Settings_Pressed"
            case .avatatPressed:        "ProfileView_Avatar_Pressed"
            case .deleteAvatarStart:    "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess:  "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFailed:   "ProfileView_DeleteAvatar_Failed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(let avatarCount):
                return ["avatar_count": avatarCount]
            case .avatatPressed(let avatar), .deleteAvatarStart(let avatar), .deleteAvatarSuccess(let avatar):
                return avatar.eventParameters
            case .loadAvatarsFailed(let error), .deleteAvatarFailed(let error):
                return error.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .loadAvatarsFailed, .deleteAvatarFailed: .severe
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension ProfileView {
    func loadData() async {
        self.currentUser = userManager.currentUser
        logManager.trackEvent(event: Event.loadAvatarsStart)
        
        do {
            let uid = currentUser?.userId ?? ""
            myAvatars = try await avatarManager.getAvatarsForAuthor(authorId: uid)
            
            logManager.trackEvent(event: Event.loadAvatarsSuccess(avatarCount: myAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFailed(error: error))
        }
        
        isLoading = false
    }
    
    func onNewAvatarButtonTap() {
        showCreateAvatarView = true
        logManager.trackEvent(event: Event.newAvatarPressed)
    }
    
    func onSettingsButtonTap() {
        showSettingsView = true
        logManager.trackEvent(event: Event.settingsPressed)
    }
    
    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatarToDelete = myAvatars[index]
        logManager.trackEvent(event: Event.deleteAvatarStart(avatar: avatarToDelete))
        
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarToDelete.avatarId)
                myAvatars.remove(at: index)
                logManager.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatarToDelete))
            } catch {
                showAlert = AppAlert(
                    title: "Unable to delete",
                    subtitle: "Please try again later"
                )
                logManager.trackEvent(event: Event.deleteAvatarFailed(error: error))
            }
        }
    }
    
    func onAvatarPress(_ avatar: Avatar) {
        option = .chat(avatar: avatar, chat: nil)
        logManager.trackEvent(event: Event.avatatPressed(avatar: avatar))
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .previewAllEnvironments()
}
