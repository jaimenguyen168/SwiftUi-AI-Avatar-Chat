//
//  OnboardingIntroView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/20/24.
//

import SwiftUI

struct OnboardingIntroView: View {
    var body: some View {
        VStack {
            introductionText
                .frame(maxHeight: .infinity)
                .padding(24)
            
            continueButton
        }
        .font(.title3)
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingIntroView")
    }
    
    private var introductionText: some View {
        Group {
            Text("Make your own ") +
            Text("avatars ")
                .foregroundStyle(.accent)
                .fontWeight(.semibold)
            +
            Text("and chat with them!\n\nHave ") +
            Text("real conversations ")
                .foregroundStyle(.accent)
                .fontWeight(.semibold)
            +
            Text("with AI generated responses.")
        }
        .baselineOffset(6)
    }
    
    private var continueButton: some View {
        NavigationLink {
            OnboardingColorView()
        } label: {
            Text("Continue")
                .callToActionButton()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingIntroView()
    }
}
