//
//  SettingsView.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/19/24.
//

import SwiftUI
import SwiftfulUtilities

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AppState.self) private var appState
    
    @Environment(LogManager.self) private var logManager
    
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = true
    @State private var showCreateAccountView: Bool = false
    
    @State private var showAlert: AppAlert?
    @State private var showRatingsModal = false
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                
                purchasesSection
                
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(
                isPresented: $showCreateAccountView,
                onDismiss: {
                    setAnonymousStatus()
                },
                content: {
                    CreateAccountView()
                        .presentationDetents([.medium])
                }
            )
            .onAppear {
                setAnonymousStatus()
            }
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "SettingsView")
            .showModal(showModal: $showRatingsModal) {
                ratingModal
            }
        }
    }
}

// MARK: Views Section
private extension SettingsView {
    var ratingModal: some View {
        CustomModalView(
            title: "Are you enjoying AI Chat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonText: "Yes",
            primaryButtonAction: {
                onEnjoyingAppYesPressed()
            },
            secondaryButtonText: "No",
            secondaryButtonAction: {
                onEnjoyingAppNoPressed()
            }
        )
    }
    
    var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .customButton(.highlight(cornerRadius: 12)) {
                        onCreateAccountTapped()
                    }
                    .clearListRowBackground()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .customButton(.highlight(cornerRadius: 12)) {
                        onSignOutTapped()
                    }
                    .clearListRowBackground()
            }
            
            Text("Delete account")
                .foregroundStyle(.red)
                .rowFormatting()
                .customButton(.highlight(cornerRadius: 12)) {
                    onDeleteAccountTapped()
                }
                .clearListRowBackground()
        } header: {
            Text("Account")
        }
    }
    
    var purchasesSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account status: \(isPremium ? "PREMIUM" : "FREE")")
                
                Spacer(minLength: 0)
                
                if isPremium {
                    Text("MANAGE")
                        .blueBadge()
                }
            }
            .rowFormatting()
            .customButton(.highlight(cornerRadius: 12)) {

            }
            .disabled(!isPremium)
            .clearListRowBackground()
        } header: {
            Text("Purchases")
        }
    }
    
    var applicationSection: some View {
        Section {
            Text("Rate Us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .customButton(.highlight(cornerRadius: 12)) {
                    rateUsTapped()
                }
                .clearListRowBackground()
            
            HStack(spacing: 8) {
                Text("Version")
                
                Spacer(minLength: 0)
                
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .clearListRowBackground()
            
            HStack(spacing: 8) {
                Text("Build Number")
                
                Spacer(minLength: 0)
                
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .clearListRowBackground()
            
            Text("Contact us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .customButton(.highlight(cornerRadius: 12)) {
                    onContactUsPress()
                }
                .clearListRowBackground()
        } header: {
            Text("Application")
        } footer: {
            VStack(alignment: .leading, spacing: 6) {
                Text("Designed by ")
                +
                Text("Swiftful Thinking.")
                    .bold()
                    .foregroundStyle(.black.opacity(0.5))
                
                Text("Developed by ")
                +
                Text("JaimeNguyen168 ")
                    .bold()
                    .foregroundStyle(.accent)
                +
                Text("with ❤️")
                
                Text("Copyright © 2021 Swiftful Thinking.")
            }
        }
    }
}

// MARK: Additional Data Section
private extension SettingsView {
    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFailed(Error)
        case createAccountPressed
        case deleteAccountStart
        case deleteAccountStartConfimred
        case deleteAccountSuccess(String)
        case deleteAccountFailed(Error)
        case contactUsPressed
        case rateUsPressed
        case ratingsYesPressed
        case ratingsNoPressed
        
        var eventName: String {
            switch self {
            case .signOutStart:                 "SettingsView_SignOut_Start"
            case .signOutSuccess:               "SettingsView_SignOut_Success"
            case .signOutFailed:                "SettingsView_SignOut_Failed"
            case .createAccountPressed:         "SettingsView_CreateAccount_Pressed"
            case .deleteAccountStart:           "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfimred:  "SettingsView_DeleteAccount_StartConfimred"
            case .deleteAccountSuccess:         "SettingsView_DeleteAccount_Success"
            case .deleteAccountFailed:          "SettingsView_DeleteAccount_Failed"
            case .contactUsPressed:             "SettingsView_ContactUs_Pressed"
            case .rateUsPressed:                "SettingsView_RateUs_Pressed"
            case .ratingsYesPressed:            "SettingsView_Ratings_Yes_Pressed"
            case .ratingsNoPressed:            "SettingsView_Ratings_No_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .deleteAccountSuccess(let uid):
                return ["uid": uid]
            case .signOutFailed(let error), .deleteAccountFailed(let error):
                return error.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .signOutFailed, .deleteAccountFailed: .severe
            default: .analytic
            }
        }
    }
}

// MARK: Logic Section
private extension SettingsView {
    func setAnonymousStatus() {
        isAnonymousUser = authManager.authUser?.isAnonymous == true
    }
    
    func onSignOutTapped() {
        logManager.trackEvent(event: Event.signOutStart)
        
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                
                logManager.trackEvent(event: Event.signOutSuccess)
                
                await dismissView()
            } catch {
                showAlert = AppAlert(error: error)
                logManager.trackEvent(event: Event.signOutFailed(error))
            }
        }
    }
    
    func onCreateAccountTapped() {
        showCreateAccountView = true
        logManager.trackEvent(event: Event.createAccountPressed)
    }
    
    func rateUsTapped() {
        logManager.trackEvent(event: Event.rateUsPressed)
        showRatingsModal = true
    }
    
    func onEnjoyingAppYesPressed() {
        logManager.trackEvent(event: Event.ratingsYesPressed)
        showRatingsModal = false
        
        AppStoreRatingsHelper.requestRatingsReview()
    }
    
    func onEnjoyingAppNoPressed() {
        logManager.trackEvent(event: Event.ratingsNoPressed)
        showRatingsModal = false
    }
    
    func onContactUsPress() {
        logManager.trackEvent(event: Event.contactUsPressed)
        
        let email = "nguyenphuocdat168@gmail.com"
        let emailString = "mailto: \(email)"
        
        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func dismissView() async {
        dismiss()
        try? await Task.sleep(for: .seconds(0.1))
        appState.updateViewState(showTabBarView: false)
    }
    
    func onDeleteAccountTapped() {
        logManager.trackEvent(event: Event.deleteAccountStart)
        
        showAlert = AppAlert(
            title: "Delete Account",
            subtitle: "This action is permanent and cannot be undone. Are you sure you want to delete your account?",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive) {
                        onDeleteAccountConfirmed()
                    }
                )
            }
        )
    }
    
    func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStartConfimred)
        
        Task {
            do {
                let uid = try authManager.getAuthId()
                
//                async let deleteAuth: () = authManager.deleteAccount()
//                async let deleteUser: () = userManager.deleteCurrentUser()
//                async let removeUser: () = avatarManager.removeAuthorIdFromAllAvatars(authorId: uid)
//                async let removeRecentAvatars: () = avatarManager.removeAllRecentAvatars()
//                async let deleteChats: () = chatManager.deleteAllChatsForUser(userId: uid)
//                
//                let (_, _, _, _, _, _) = await
//                (
//                    try deleteAuth,
//                    try deleteUser,
//                    try removeUser,
//                    try removeRecentAvatars,
//                    try deleteChats,
//                    logManager.deleteUserProfile()
//                )
                try await authManager.deleteAccount()
                try await userManager.deleteCurrentUser()
                try await avatarManager.removeAuthorIdFromAllAvatars(authorId: uid)
                try await avatarManager.removeAllRecentAvatars()
                try await chatManager.deleteAllChatsForUser(userId: uid)
                
                logManager.deleteUserProfile()
                logManager.trackEvent(event: Event.deleteAccountSuccess(uid))
                
                await dismissView()
            } catch {
                showAlert = AppAlert(error: error)
                logManager.trackEvent(event: Event.deleteAccountFailed(error))
            }
        }
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
    }
    
    func clearListRowBackground() -> some View {
        self
            .listRowInsets(EdgeInsets(.zero))
            .listRowBackground(Color.clear)
    }
}

#Preview("Non Auth") {
    SettingsView()
//        .environment(\.authService, MockAuthService(user: nil))
        .previewAllEnvironments()
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(authService: MockAuthService(authUser: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(userServices: MockUserServices(user: .mock)))
        .previewAllEnvironments()
}

#Preview("Non Anonymous") {
    SettingsView()
        .environment(AuthManager(authService: MockAuthService(authUser: UserAuthInfo.mock(isAnonymous: false))))
        .previewAllEnvironments()
}
