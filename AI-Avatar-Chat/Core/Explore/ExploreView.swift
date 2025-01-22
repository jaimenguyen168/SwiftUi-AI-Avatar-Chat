//
//  ExploreView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var categories: [Character] = Character.allCases
    
    @State private var featuredAvatars: [Avatar] = []
    @State private var popularAvatars: [Avatar] = []
    @State private var isFeatureLoading = true
    @State private var isPopularLoading = true
    
    let carouselWidth = customWidth(percent: 90)
    
    @State private var option: NavigationCoreOption?
    
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
            .navigationDestinationCoreOption(option: $option)
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
}

// MARK: Logic Section
private extension ExploreView {
    func loadFeaturedAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
        } catch {
            print("DEBUG: Loading featured avatars failed with error \(error.localizedDescription)")
        }
        
        isFeatureLoading = false
    }
    
    func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
        } catch {
            print("DEBUG: Loading popular avatars failed with error \(error.localizedDescription)")
        }
        
        isPopularLoading = false
    }
    
    func onAvatarPress(_ avatar: Avatar) {
        option = .chat(avatar: avatar)
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
    }
    
    func onRetryPress() {
        isFeatureLoading = true
        isPopularLoading = true
        
        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
}

#Preview("Has Data") {
    ExploreView()
        .environment(AvatarManager(avatarService: MockAvatarService()
        )
    )
}

#Preview("No Data") {
    ExploreView()
        .environment(AvatarManager(
            avatarService: MockAvatarService(
                avatars: [],
                delay: 1.0
            )
        )
    )
}

#Preview("Slow Loading") {
    ExploreView()
        .environment(AvatarManager(
            avatarService: MockAvatarService(delay: 5.0)
        )
    )
}
