//
//  WelcomeView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct WelcomeView: View {
    
    @State var imageUrl = Constants.randomImageUrl
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ImageLoaderView(urlString: imageUrl)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top, 24)
               
                onboardingButtons
                    .padding(16)
                
                termsAndPolicyLink
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("AI Avatar Chat 👽")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("@ Jaime168 & @ SwiftfulThinking")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var onboardingButtons: some View {
        VStack {
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }
            
            Text("Already have an account? **Sign In!**")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    
                }
        }
    }
    
    private var termsAndPolicyLink: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceUrl)!) {
                Text("Terms of Service")
            }
            
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            
            Link(destination: URL(string: Constants.privacyPolicyUrl)!) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview {
    WelcomeView()
}
