//
//  UserManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/14/25.
//

import SwiftUI

@MainActor
@Observable
class UserManager {
    
    private let remote: RemoteUserService
    private let local: LocalUserPersistenceService
    private let logManager: LogManager?
    
    private(set) var currentUser: AppUser?
    
    init(userServices: UserServices, logManager: LogManager? = nil) {
        self.remote = userServices.remote
        self.local = userServices.local
        self.currentUser = local.getCurrentUser()
        
        self.logManager = logManager
    }
    
    func login(userAuth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = AppUser(authUser: userAuth, creationVersion: creationVersion)
        logManager?.trackEvent(event: Event.logInStart(user))
        
        try await remote.saveUser(user: user)
        logManager?.trackEvent(event: Event.logInSuccess(user))
        
        addCurrentUserListener(userId: userAuth.uid)
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingComplete(userId: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUser = nil
        logManager?.trackEvent(event: Event.signOut)
    }
    
    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        signOut()
    }
    
    private func addCurrentUserListener(userId: String) {
        logManager?.trackEvent(event: Event.remoteListenerStart)
        
        Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value
                    saveCurrentUserLocally()
                    logManager?.trackEvent(event: Event.remoteListenerSuccess(value))
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                }
            } catch {
                logManager?.trackEvent(event: Event.remoteListenerFailed(error))
            }
        }
    }
    
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    private func saveCurrentUserLocally() {
        logManager?.trackEvent(event: Event.saveLocalStart(currentUser))
        
        Task {
            do {
                try local.saveCurrentUser(currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFailed(error))
            }
        }
    }
}
 
// MARK: Additional Data Section
private extension UserManager {
    enum UserManagerError: LocalizedError {
        case noUserId
    }
    
    enum Event: LoggableEvent {
        case logInStart(AppUser?)
        case logInSuccess(AppUser?)
        case remoteListenerStart
        case remoteListenerSuccess(AppUser?)
        case remoteListenerFailed(Error)
        case saveLocalStart(AppUser?)
        case saveLocalSuccess(AppUser?)
        case saveLocalFailed(Error)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess
        
        var eventName: String {
            switch self {
            case .logInStart:               "UserManager_LogIn_Start"
            case .logInSuccess:             "UserManager_LogIn_Success"
            case .remoteListenerStart:      "UserManager_RemoteListener_Start"
            case .remoteListenerSuccess:    "UserManager_RemoteListener_Success"
            case .remoteListenerFailed:     "UserManager_RemoteListener_Failed"
            case .saveLocalStart:           "UserManager_SaveLocal_Start"
            case .saveLocalSuccess:         "UserManager_SaveLocal_Success"
            case .saveLocalFailed:          "UserManager_SaveLocal_Failed"
            case .signOut:                  "UserManager_SignOut"
            case .deleteAccountStart:       "UserManager_DeleteAccount_Start"
            case .deleteAccountSuccess:     "UserManager_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .logInStart(let user),
                    .logInSuccess(let user),
                    .remoteListenerSuccess(let user),
                    .saveLocalStart(let user),
                    .saveLocalSuccess(let user):
                return user?.eventParameters
            case .saveLocalFailed(let error), .remoteListenerFailed(let error):
                return error.eventParameters
            default: return nil
            }
        }
        
        var logType: LogType {
            switch self {
            case .saveLocalFailed, .remoteListenerFailed: .severe
            default: .analytic
            }
        }
    }
}
