//
//  ExploreView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @State private var featuredAvatars: [Avatar] = []
    @State private var popularAvatars: [Avatar] = []
    
    @State private var categories: [Character] = Character.allCases
    let carouselWidth = customWidth(percent: 90)
    
    @State private var option: NavigationCoreOption?
    
    var body: some View {
        NavigationStack {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    
                    ProgressView()
                        .formatListRow()
                        .frame(maxWidth: .infinity)
                        .frame(height: 500)
                        .scaleEffect(1.5)
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

// View sections
private extension ExploreView {
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
                            let imageName = popularAvatars.first(where: {
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
            ForEach(popularAvatars, id: \.self) { avatar in
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

// Logic sections
private extension ExploreView {
    func loadFeaturedAvatars() async {
        guard featuredAvatars.isEmpty else { return }
        
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
        } catch {
            print("DEBUG: Loading featured avatars failed with error \(error.localizedDescription)")
        }
    }
    
    func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
        } catch {
            print("DEBUG: Loading popular avatars failed with error \(error.localizedDescription)")
        }
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
}

#Preview {
    ExploreView()
        .navigationTitle(TabBarItem.explore.rawValue.capitalized)
        .environment(AvatarManager(avatarService: FirebaseAvatarService()))
}
