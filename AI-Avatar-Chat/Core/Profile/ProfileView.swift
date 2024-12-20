//
//  ProfileView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var showSettingsView: Bool = false
    
    var body: some View {
        VStack {
            Text("Hello, Profile!")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingButton
                    }
                }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
    }
    
    private var settingButton: some View {
        Button {
            onSettingsButtonTap()
        } label: {
            Image(systemName: "gear")
                .font(.headline)
        }
    }
    
    private func onSettingsButtonTap() {
        showSettingsView = true
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .navigationTitle(TabBarItem.profile.rawValue.capitalized)
    }
}
