//
//  CategoryListView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/7/25.
//

import SwiftUI

struct CategoryListView: View {
    
    var category: Character = .default
    var imageName = Constants.randomImageUrl
    @State private var avatars: [Avatar] = Avatar.mocks
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageUrl: imageName,
                font: .title,
                cornerRadius: 0
            )
            .removeBgAndInsetsListRow()
            
            ForEach(avatars) { avatar in
                CustomListCellView(
                    title: avatar.name,
                    subtitle: avatar.description,
                    imageUrl: avatar.profileImageUrl
                )
            }
            .removeBgAndInsetsListRow()
            .padding(6)
        }
        .ignoresSafeArea()
        .listStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CategoryListView()
    }
}
