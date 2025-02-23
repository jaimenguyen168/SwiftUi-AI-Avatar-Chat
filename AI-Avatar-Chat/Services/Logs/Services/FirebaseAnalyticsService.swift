//
//  FirebaseAnalyticsService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/9/25.
//

import SwiftUI
import FirebaseAnalytics

fileprivate extension String {
    func clean(maxCharacters: Int) -> String {
        self
            .clipped(maxCharacters: maxCharacters)
            .replacingOccurrences(of: "\n", with: " ")
    }
}

struct FirebaseAnalyticsService: LogService {
    
    func identifyUser(userId: String, name: String?, email: String?) {
        Analytics.setUserID(userId)
        
        if let name = name {
            Analytics.setUserProperty(name, forName: "account_name")
        }
        
        if let email = email {
            Analytics.setUserProperty(email, forName: "account_email")
        }
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        
        for (key, value) in dict {
            if let stringValue = String.convertToString(value) {
                let key = key.clean(maxCharacters: 24)
                let stringValue = stringValue.clean(maxCharacters: 100)
                
                Analytics.setUserProperty(stringValue, forName: key)
            }
        }
    }
    
    func trackEvent(event: any LoggableEvent) {
        guard event.logType != .info else { return }
        
        var parameters = event.parameters ?? [:]
        
//        // fix bad-type values
//        for (key, value) in parameters {
//            if let date = value as? Date, let string = String.convertToString(date) {
//                parameters[key] = string
//            } else if let array = value as? [Any] {
//                if let string = String.convertToString(array) {
//                    parameters[key] = string
//                } else {
//                    parameters[key] = nil
//                }
//            }
//        }
//        
//        // fix key length limit
//        for (key, value) in parameters where key.count > 40 {
//            parameters.removeValue(forKey: key)
//            
//            let newkey = key.clean(maxCharacters: 40)
//            parameters[newkey] = value
//        }
//        
//        // fix value length limit
//        for (key, value) in parameters {
//            if let stringValue = value as? String {
//                parameters[key] = stringValue.clean(maxCharacters: 100)
//            }
//        }
        
        parameters = parameters.reduce(into: [:]) { result, entry in
            let (key, value) = entry
            var sanitizedValue: Any? = value
            var sanitizedKey = key

            // Fix bad-type values
            if let date = value as? Date {
                sanitizedValue = String.convertToString(date)
            } else if let array = value as? [Any] {
                sanitizedValue = String.convertToString(array) ?? nil
            }

            // Fix key length limit
            if key.count > 40 {
                sanitizedKey = key.clean(maxCharacters: 40)
            }

            // Fix value length limit
            if let stringValue = sanitizedValue as? String {
                sanitizedValue = stringValue.clean(maxCharacters: 100)
            }

            if let sanitizedValue = sanitizedValue {
                result[sanitizedKey] = sanitizedValue
            }
        }
        
        parameters.first(upTo: 25)
        let name = event.eventName.clean(maxCharacters: 40)
        Analytics.logEvent(name, parameters: parameters.isEmpty ? nil : parameters)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        let name = event.eventName.clean(maxCharacters: 40)
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
    }
    
    /// no equivalent analytics for now
    func deleteUserProfile() {}
}
