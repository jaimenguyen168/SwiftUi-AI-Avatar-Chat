//
//  OnboardingCompletedView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    @State private var isCompleting: Bool = false
    var selectedColor: Color = .cyan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
            Text("We've successfully set up your AI avatar chat account. You are now ready to start chatting with your new AI-generated friend!")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

        }
        .toolbar(.hidden, for: .navigationBar)
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            AsyncCallToActionButton(
                title: "Finish",
                isLoading: isCompleting,
                action: onFinishButtonTapped
            )
        })
        .padding(24)
    }
}

private extension OnboardingCompletedView {
    func onFinishButtonTapped() {
        isCompleting = true
        Task {
//            try await Task.sleep(for: .seconds(2))
//            isCompleting = false
            let hex = selectedColor.asHex()
            try await userManager
                .markOnboardingCompleteForCurrentUser(profileColorHex: hex)
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(AppState())
        .environment(UserManager(userServices: MockUserServices(user: .mock)))
}
