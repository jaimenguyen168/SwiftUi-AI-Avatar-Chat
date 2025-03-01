//
//  CreateAccountView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/24/24.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    @Environment(LogManager.self) private var logManager
    
    @Environment(\.dismiss) private var dismiss
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account information."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(subtitle)
                    .font(.subheadline)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 55)
            .frame(maxWidth: 400)
            .customButton(.pressable) {
                onSignInWithApplePress()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
        .frame(maxHeight: 500)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: Additional Data Section
private extension CreateAccountView {
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFailed(error: Error)
        
        var eventName: String {
            switch self {
            case .appleAuthStart:           "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess:         "CreateAccountView_AppleAuth_Success"
            case .appleAuthLoginSuccess:    "CreateAccountView_AppleAuth_LoginSuccess"
            case .appleAuthFailed:          "CreateAccountView_AppleAuth_Failed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
                return dict
            case .appleAuthFailed(error: let error):
                return error.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .appleAuthFailed: .severe
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension CreateAccountView {
    func onSignInWithApplePress() {
        logManager.trackEvent(event: Event.appleAuthStart)
        
        Task {
            do {
                let result = try await authManager.signInWithApple()
                logManager.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))
                
                try await userManager.login(userAuth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))
                
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.appleAuthFailed(error: error))
            }
        }
    }
}

#Preview {
    CreateAccountView()
        .environment(AuthManager(authService: MockAuthService(authUser: nil)))
        .environment(UserManager(userServices: MockUserServices(user: nil)))
        .previewAllEnvironments()
}
