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
    let carouselWidth = customWidth(percent: 90)
    
    var body: some View {
        List {
            featuredSection
            
            categorySection
        }
        .listStyle(.plain)
    }
    
    private var featuredSection: some View {
        Section {
            ZStack { // put in Zstack helps remove the glitch when swiping
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.description,
                        imageUrl: avatar.profileImageUrl
                    )
                    .frame(width: carouselWidth, height: 200)
                }
            }
            .formatListRow()
        } header: {
            Text("Featured Avatars")
                .textCase(.uppercase)
        }
    }
    
    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories) { category in
                            CategoryCellView(
                                title: category.rawValue.capitalized,
                                imageUrl: Constants.randomImageUrl
                            )
                            .offset(x: 20)
                        }
                    }
                }
                .frame(height: 150)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
            }
            .formatListRow()
        } header: {
            Text("Categories")
                .textCase(.uppercase)
        }
    }
}

#Preview {
    NavigationStack {
        ExploreView()
            .navigationTitle(TabBarItem.explore.rawValue.capitalized)
    }
}
