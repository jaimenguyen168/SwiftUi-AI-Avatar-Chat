//
//  FirebaseCrashlyticsService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/18/25.
//

import FirebaseCrashlytics

struct FirebaseCrashlyticsService: LogService {
    func identifyUser(userId: String, name: String?, email: String?) {
        Crashlytics.crashlytics().setUserID(userId)
        
        if let name = name {
            Crashlytics.crashlytics().setCustomValue(name, forKey: "account_name")
        }
        
        if let email = email {
            Crashlytics.crashlytics().setCustomValue(name, forKey: "account_email")
        }
    }
    
    func addUserProperties(dict: [String : Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        
        for (key, value) in dict {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
    }
    
    func deleteUserProfile() {
        Crashlytics.crashlytics().setUserID("new_user")
    }
    
    func trackEvent(event: any LoggableEvent) {
        switch event.logType {
        case .info, .warning, .analytic:
            break
        case .severe:
            let error = NSError(
                domain: event.eventName,
                code: event.eventName.stableHashValue,
                userInfo: event.parameters
            )
            Crashlytics.crashlytics().record(error: error, userInfo: event.parameters)
        }
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
