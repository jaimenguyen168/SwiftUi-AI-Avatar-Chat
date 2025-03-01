//
//  WelcomeView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(AppState.self) private var root
    
    @Environment(LogManager.self) private var logManager
    
    @State var imageUrl = Constants.randomImageUrl
    @State private var showSignInAccountView: Bool = false
    
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
        .screenAppearAnalytics(name: "WelcomeView")
        .sheet(isPresented: $showSignInAccountView) {
            CreateAccountView(
                title: "Sign In",
                subtitle: "Connect to an existing account",
                onDidSignIn: { isNewUser in
                    handleDidSignIn(isNewUser: isNewUser)
                }
            )
            .presentationDetents([.medium])
        }
    }
}

// MARK: Views Section
private extension WelcomeView {
    var titleSection: some View {
        VStack(spacing: 8) {
            Text("AI Avatar Chat 👽")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("@ Jaime168 & @ SwiftfulThinking")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    var onboardingButtons: some View {
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
                    onSignInTapped()
                }
                .lineLimit(1)
                .minimumScaleFactor(0.4)
        }
    }
    
    var termsAndPolicyLink: some View {
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
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
}

// MARK: Additional Data Section
private extension WelcomeView {
    enum Event: LoggableEvent {
        case signInPressed
        case didSignIn(Bool)
        
        var eventName: String {
            switch self {
            case .signInPressed:    "WelcomeView_SignIn_Pressed"
            case .didSignIn:        "WelcomeView_DidSignIn"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(let isNewUser):
                return ["is_new_user": isNewUser]
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension WelcomeView {
    func onSignInTapped() {
        showSignInAccountView = true
        logManager.trackEvent(event: Event.signInPressed)
    }
    
    func handleDidSignIn(isNewUser: Bool) {
        logManager.trackEvent(event: Event.didSignIn(isNewUser))
        if isNewUser {
            // Do nothing
        } else {
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    WelcomeView()
        .previewAllEnvironments()
}
