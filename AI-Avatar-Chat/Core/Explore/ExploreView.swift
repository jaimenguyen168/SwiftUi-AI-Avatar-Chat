//
//  ExploreView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ExploreView: View {
    
    @State private var featuredAvatars: [Avatar] = Avatar.mocks
    @State private var categories: [Character] = Character.allCases
    @State private var popularAvatars: [Avatar] = Avatar.mocks
    let carouselWidth = customWidth(percent: 90)
    
    @State private var option: NavigationCoreOption?
    
    var body: some View {
        NavigationStack {
            List {
                featuredSection
                
                categorySection
                
                popularSection
            }
            .listStyle(.grouped)
            .navigationTitle("Explore")
            .navigationDestinationCoreOption(option: $option)
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
}
