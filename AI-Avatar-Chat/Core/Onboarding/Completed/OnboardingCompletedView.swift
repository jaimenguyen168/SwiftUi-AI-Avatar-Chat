//
//  OnboardingCompletedView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    
    var body: some View {
        VStack {
            Text("Completed")
                .frame(maxHeight: .infinity)
            
            Button {
                onFinishButtonTapped()
            } label: {
                Text("Finish")
                    .callToActionButton()
            }

        }
        .padding(16)
    }
    
    private func onFinishButtonTapped() {
        root.updateViewState(showTabBarView: true)
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
