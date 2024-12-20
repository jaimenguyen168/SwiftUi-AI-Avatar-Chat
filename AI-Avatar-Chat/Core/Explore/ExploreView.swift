//
//  ExploreView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        Text("Hello, Explore!")
    }
}

#Preview {
    NavigationStack {
        ExploreView()
            .navigationTitle(TabBarItem.explore.rawValue.capitalized)
    }
}
