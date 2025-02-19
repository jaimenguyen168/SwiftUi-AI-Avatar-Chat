//
//  CategoryListView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/7/25.
//

import SwiftUI

struct CategoryListView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
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
        .screenAppearAnalytics(name: "CategoryList")
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

// MARK: Additional Data Section
private extension CategoryListView {
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess
        case loadAvatarFailed(error: Error)
        case avatarPressed(avatar: Avatar)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart: "CategoryList_LoadAvatar_Start"
            case .loadAvatarSuccess: "CategoryList_LoadAvatar_Success"
            case .loadAvatarFailed: "CategoryList_LoadAvatar_Failed"
            case .avatarPressed: "CategoryList_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFailed(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .loadAvatarFailed: .severe
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension CategoryListView {
    func loadAvatars() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarSuccess)
        } catch {
            showAlert = AppAlert(error: error)
            logManager.trackEvent(event: Event.loadAvatarFailed(error: error))
        }
        
        isLoading = false
    }
    
    func onAvatarPress(_ avatar: Avatar) {
        option = .chat(avatar: avatar, chat: nil)
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
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
            .previewAllEnvironments()
    }
}

#Preview("Has Data") {
    NavigationStack {
        CategoryListView()
            .previewAllEnvironments()
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
            .previewAllEnvironments()
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
            .previewAllEnvironments()
    }
}
