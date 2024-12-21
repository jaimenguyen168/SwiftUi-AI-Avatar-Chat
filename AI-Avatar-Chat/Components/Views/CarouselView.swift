//
//  CarouselView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/20/24.
//

import SwiftUI

struct CarouselView<Content: View, T: Hashable>: View {
    
    var items: [T]
    @ViewBuilder var content: (T) -> Content
    @State private var selectedAvatar: T?
    
    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .id(item)
                            .scrollTransition(
                                .interactive.threshold(.visible(0.9)),
                                transition: { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.7)
                                }
                            )
                            .containerRelativeFrame(.horizontal, alignment: .center)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selectedAvatar)
            .onChange(of: items.count, { _, _ in // when new avatars are passed in
                updateSelectionIfNeeded()
            })
            .onAppear {
                updateSelectionIfNeeded()
            }
            
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { avatar in
                    Circle()
                        .fill(avatar == selectedAvatar ? .accent : .secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selectedAvatar)
        }
    }
    
    private func updateSelectionIfNeeded() {
        if selectedAvatar == nil || selectedAvatar == items.last {
            selectedAvatar = items.first
        }
    }
}

#Preview {
    CarouselView(items: Avatar.mocks) { avatar in
        HeroCellView(
            title: avatar.name,
            subtitle: avatar.description,
            imageUrl: avatar.profileImageUrl
        )
    }
    .frame(width: .infinity, height: 250)
    .padding()
    
    CarouselView(items: Avatar.mocks) { avatar in
        HeroCellView(
            title: avatar.name,
            subtitle: avatar.description,
            imageUrl: avatar.profileImageUrl
        )
    }
    .frame(width: 200, height: 200)
}
