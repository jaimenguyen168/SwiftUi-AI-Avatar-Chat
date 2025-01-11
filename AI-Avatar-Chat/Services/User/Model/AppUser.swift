//
//  User.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/23/24.
//

import Foundation
import SwiftUI

struct AppUser {
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        dateCreated: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    var profileColorSwift: Color? {
        guard let profileColorHex else { return .accent }
        return Color.fromHex(profileColorHex)
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            AppUser(
                userId: "mockUser1",
                dateCreated: now.addTimeInterval(days: -1),
                didCompleteOnboarding: true,
                profileColorHex: "#FF5733"
            ),
            AppUser(
                userId: "mockUser2",
                dateCreated: now.addTimeInterval(days: -7),
                didCompleteOnboarding: false,
                profileColorHex: "#33A1FF"
            ),
            AppUser(
                userId: "mockUser3",
                dateCreated: now.addTimeInterval(days: -30),
                didCompleteOnboarding: true,
                profileColorHex: "#B833FF"
            ),
            AppUser(
                userId: "mockUser4",
                dateCreated: nil, // No date created
                didCompleteOnboarding: false,
                profileColorHex: "#33FF57"
            ),
            AppUser(
                userId: "mockUser5",
                dateCreated: now,
                didCompleteOnboarding: nil,
                profileColorHex: "#FFFFFF"
            )
        ]
    }
}
