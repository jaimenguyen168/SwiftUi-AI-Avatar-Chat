//
//  User.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/23/24.
//

import Foundation
import SwiftUI

struct AppUser: Codable {
    
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    let creationVersion: String?
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil,
        creationVersion: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
        self.creationVersion = creationVersion
    }
    
    init(authUser: UserAuthInfo, creationVersion: String?) {
        self.init(
            userId: authUser.uid,
            email: authUser.email,
            isAnonymous: authUser.isAnonymous,
            creationDate: authUser.creationDate,
            lastSignInDate: authUser.lastSignInDate,
            creationVersion: creationVersion
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
        case creationVersion = "creation_version"
    }
    
    var profileColorSwift: Color? {
        guard let profileColorHex else { return .accent }
        return Color.fromHex(profileColorHex)
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "user_\(CodingKeys.userId.rawValue)": userId,
            "user_\(CodingKeys.email.rawValue)": email,
            "user_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "user_\(CodingKeys.creationDate.rawValue)": creationDate?.description,
            "user_\(CodingKeys.creationVersion.rawValue)": creationVersion,
            "user_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "user_\(CodingKeys.didCompleteOnboarding.rawValue)": didCompleteOnboarding,
            "user_\(CodingKeys.profileColorHex.rawValue)": profileColorHex
        ]
        
        return dict.compactMapValues { $0 } // drop values if nil
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            AppUser(
                userId: "mockUser1",
                creationDate: now.addTimeInterval(days: -1),
                didCompleteOnboarding: true,
                profileColorHex: "#FF5733"
            ),
            AppUser(
                userId: "mockUser2",
                creationDate: now.addTimeInterval(days: -7),
                didCompleteOnboarding: false,
                profileColorHex: "#33A1FF"
            ),
            AppUser(
                userId: "mockUser3",
                creationDate: now.addTimeInterval(days: -30),
                didCompleteOnboarding: true,
                profileColorHex: "#B833FF"
            ),
            AppUser(
                userId: "mockUser4",
                creationDate: nil, // No date created
                didCompleteOnboarding: false,
                profileColorHex: "#33FF57"
            ),
            AppUser(
                userId: "mockUser5",
                creationDate: now,
                didCompleteOnboarding: nil,
                profileColorHex: "#FFFFFF"
            )
        ]
    }
}
