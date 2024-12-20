//
//  ExploreView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ExploreView: View {
    
    let avatar = Avatar.mock
    
    var body: some View {
        HeroCellView(
            title: avatar.name,
            subtitle: avatar.description,
            imageUrl: avatar.profileImageUrl
        )
        .frame(height: 200)
    }
}

#Preview {
    NavigationStack {
        ExploreView()
            .navigationTitle(TabBarItem.explore.rawValue.capitalized)
    }
}
