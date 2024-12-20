//
//  OnboardingCompletedView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
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
            finishButton
        })
        .padding(24)
    }
    
    private var finishButton: some View {
        Button {
            onFinishButtonTapped()
        } label: {
            ZStack {
                if isCompleting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Finish")
                }
            }
            .callToActionButton()
        }
        .disabled(isCompleting)
    }
    
    private func onFinishButtonTapped() {
        isCompleting = true
        Task {
            try await Task.sleep(for: .seconds(2))
            isCompleting = false
            
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(AppState())
}
