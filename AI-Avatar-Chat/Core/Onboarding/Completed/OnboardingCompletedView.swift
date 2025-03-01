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
    
    @Environment(LogManager.self) private var logManager
    
    @State private var isCompleting: Bool = false
    var selectedColor: Color = .cyan
    
    @State private var showAlert: AppAlert?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
            Text("We've successfully set up your account and you're' now ready to start chatting!")
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
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $showAlert)
    }
}

// MARK: Additional Data Section
private extension OnboardingCompletedView {
    enum Event: LoggableEvent {
        case finishOnboardingStart
        case finishOnboardingSuccess(hex: String)
        case finishOnboardingFailed(error: Error)
        
        var eventName: String {
            switch self {
            case .finishOnboardingStart:    "OnboardingCompleted_FinishOnboarding_Start"
            case .finishOnboardingSuccess:  "OnboardingCompleted_FinishOnboarding_Success"
            case .finishOnboardingFailed:   "OnboardingCompleted_FinishOnboarding_Failed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishOnboardingSuccess(hex: let hex):
                return ["profile_color_hex": hex]
            case .finishOnboardingFailed(let error):
                return error.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .finishOnboardingFailed: .severe
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension OnboardingCompletedView {
    func onFinishButtonTapped() {
        isCompleting = true
        logManager.trackEvent(event: Event.finishOnboardingStart)
        
        Task {
            do {
                let hex = selectedColor.asHex()
                try await userManager
                    .markOnboardingCompleteForCurrentUser(profileColorHex: hex)
                
                logManager.trackEvent(event: Event.finishOnboardingSuccess(hex: hex))
                
                root.updateViewState(showTabBarView: true)
            } catch {
                logManager.trackEvent(event: Event.finishOnboardingFailed(error: error))
            }
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(AppState())
        .environment(UserManager(userServices: MockUserServices(user: .mock)))
        .previewAllEnvironments()
}
