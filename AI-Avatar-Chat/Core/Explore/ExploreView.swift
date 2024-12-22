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
    
    var body: some View {
        List {
            featuredSection
            
            categorySection
            
            popularSection
        }
        .listStyle(.grouped)
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
            Text("Featured")
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
    
    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    title: avatar.name,
                    subtitle: avatar.description,
                    imageUrl: avatar.profileImageUrl
                )
                .formatListRow()
                .padding(.horizontal)
            }
        } header: {
            Text("Popular")
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
