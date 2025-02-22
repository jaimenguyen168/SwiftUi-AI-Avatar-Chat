//
//  ExploreView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    @Environment(LogManager.self) private var logManager
    
    @State private var categories: [Character] = Character.allCases
    
    @State private var featuredAvatars: [Avatar] = []
    @State private var popularAvatars: [Avatar] = []
    @State private var isFeatureLoading = true
    @State private var isPopularLoading = true
    
    let carouselWidth = customWidth(percent: 90)
    
    @State private var option: NavigationCoreOption?
    
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    @State private var showDevSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    
                    ZStack {
                        if isFeatureLoading || isPopularLoading {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .formatListRow()
                }
                
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Explore")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .navigationDestinationCoreOption(option: $option)
            .screenAppearAnalytics(name: "ExploreView")
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
        }
    }
}

// MARK: Views Section
private extension ExploreView {
    var loadingIndicator: some View {
        ProgressView()
            .tint(.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 500)
            .scaleEffect(1.2)
    }
    
    var errorMessageView: some View {
        VStack(spacing: 12) {
            Text("Error")
                .font(.headline)
            
            Text("No data found. Please try again later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Retry") {
                onRetryPress()
            }
            .tappableBackground()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
        .padding(.vertical, 64)
    }
    
    var featuredSection: some View {
        Section {
            ZStack { // put in Zstack helps remove the glitch when swiping
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.description,
                        imageUrl: avatar.profileImageUrl
                    )
                    .frame(width: carouselWidth, height: 200)
                    .customButton {
                        onAvatarPress(avatar)
                    }
                }
            }
            .formatListRow()
        } header: {
            Text("Featured")
                .textCase(.uppercase)
        }
    }
    
    var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories) { category in
                            let imageName = popularAvatars.last(where: {
                                $0.character == category
                            })?.profileImageUrl
                            
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageUrl: imageName
                                )
                                .offset(x: 20)
                                .customButton(.pressable) {
                                    onCategoryPress(
                                        category: category,
                                        imageName: imageName
                                    )
                                }
                            }
                        }
                    }
                }
                .frame(height: 140)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
            }
            .formatListRow()
        } header: {
            Text("Categories")
                .textCase(.uppercase)
        }
    }
    
    var popularSection: some View {
        Section {
            ForEach(popularAvatars.first(upTo: 5) ?? [], id: \.self) { avatar in
                CustomListCellView(
                    title: avatar.name,
                    subtitle: avatar.description,
                    imageUrl: avatar.profileImageUrl
                )
                .tappableBackground()
                .customButton(.highlight(cornerRadius: 16)) {
                    onAvatarPress(avatar)
                }
                .formatListRow()
                .padding(.horizontal)
            }
        } header: {
            Text("Popular")
                .textCase(.uppercase)
        }
    }
    
    var devSettingsButton: some View {
        Text("DEV 🤐")
            .blueBadge()
            .customButton(.pressable) {
                onDevSettingsPress()
            }
    }
}

// MARK: Additional Data Section
private extension ExploreView {
    enum Event: LoggableEvent {
        case loadFeatureAvatarsStart
        case loadFeatureAvatarsSuccess(avatarCount: Int)
        case loadFeatureAvatarsFailed(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(avatarCount: Int)
        case loadPopularAvatarsFailed(error: Error)
        case avatarPressed(avatar: Avatar)
        case categoryPressed(category: Character)
        case devSettingsPressed
        case tryAgainPressed
        
        var eventName: String {
            switch self {
            case .loadFeatureAvatarsStart:      "ExploreView_LoadFeatureAvatar_Start"
            case .loadFeatureAvatarsSuccess:    "ExploreView_LoadFeatureAvatar_Success"
            case .loadFeatureAvatarsFailed:     "ExploreView_LoadFeatureAvatar_Failed"
            case .loadPopularAvatarsStart:      "ExploreView_LoadPopularAvatar_Start"
            case .loadPopularAvatarsSuccess:    "ExploreView_LoadPopularAvatar_Success"
            case .loadPopularAvatarsFailed:     "ExploreView_LoadPopularAvatar_Failed"
            case .avatarPressed:                "ExploreView_Avatar_Pressed"
            case .categoryPressed:              "ExploreView_Category_Pressed"
            case .devSettingsPressed:           "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed:              "ExploreView_TryAgain_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadFeatureAvatarsSuccess(avatarCount: let count),
                    .loadPopularAvatarsSuccess(avatarCount: let count):
                return ["avatars_count": count]
            case .loadPopularAvatarsFailed(error: let error),
                    .loadFeatureAvatarsFailed(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(category: let category):
                return ["category": category.rawValue]
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .loadFeatureAvatarsFailed, .loadPopularAvatarsFailed: .severe
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension ExploreView {
    func loadFeaturedAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeatureAvatarsStart)
        
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeatureAvatarsSuccess(avatarCount: featuredAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadFeatureAvatarsFailed(error: error))
        }
        
        isFeatureLoading = false
    }
    
    func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(avatarCount: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFailed(error: error))
        }
        
        isPopularLoading = false
    }
    
    func onAvatarPress(_ avatar: Avatar) {
        option = .chat(avatar: avatar, chat: nil)
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    func onCategoryPress(
        category: Character,
        imageName: String
    ) {
        option = 
            .category(
            category: category,
            imageName: imageName
        )
        logManager.trackEvent(event: Event.categoryPressed(category: category))
    }
    
    func onRetryPress() {
        isFeatureLoading = true
        isPopularLoading = true
        logManager.trackEvent(event: Event.tryAgainPressed)
        
        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    func onDevSettingsPress() {
        logManager.trackEvent(event: Event.devSettingsPressed)
        showDevSettings = true
    }
}

#Preview("Has Data") {
    ExploreView()
        .environment(AvatarManager(avatarService: MockAvatarService()))
        .previewAllEnvironments()
}

#Preview("No Data") {
    ExploreView()
        .environment(AvatarManager(
            avatarService: MockAvatarService(
                avatars: [],
                delay: 1.0
            )
        ))
        .previewAllEnvironments()
}

#Preview("Slow Loading") {
    ExploreView()
        .environment(AvatarManager(
            avatarService: MockAvatarService(delay: 5.0)
        ))
        .previewAllEnvironments()
}
