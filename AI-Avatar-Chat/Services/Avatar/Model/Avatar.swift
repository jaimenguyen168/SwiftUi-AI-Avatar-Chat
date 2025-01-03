//
//  Avatar.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/20/24.
//

import Foundation

struct Avatar: Hashable {
    let avatarId: String
    let name: String?
    let character: Character?
    let action: Action?
    let location: Location?
    let profileImageUrl: String?
    
    let authodId: String?
    let dateCreated: Date
    
    var description: String {
        AvatarDescriptionBuilder(avatar: self).description
    }
    
    init(
        avatarId: String,
        name: String? = nil,
        character: Character? = nil,
        action: Action? = nil,
        location: Location? = nil,
        profileImageUrl: String? = nil,
        authodId: String? = nil,
        dateCreated: Date = Date()
    ) {
        self.avatarId = avatarId
        self.name = name
        self.character = character
        self.action = action
        self.location = location
        self.profileImageUrl = profileImageUrl
        self.authodId = authodId
        self.dateCreated = dateCreated
    }
    
    static var mock: Avatar {
        mocks[0]
    }
    
    static var mocks: [Avatar] {
        [
            Avatar(
                avatarId: UUID().uuidString,
                name: "Alpha",
                character: .alien,
                action: .eating,
                location: .beach,
                profileImageUrl: Constants.randomImageUrl,
                authodId: UUID().uuidString,
                dateCreated: .now
            ),
            Avatar(
                avatarId: UUID().uuidString,
                name: "Beta",
                character: .dog,
                action: .smiling,
                location: .space,
                profileImageUrl: Constants.randomImageUrl,
                authodId: UUID().uuidString,
                dateCreated: .now
            ),
            Avatar(
                avatarId: UUID().uuidString,
                name: "Gamma",
                character: .cat,
                action: .working,
                location: .desert,
                profileImageUrl: Constants.randomImageUrl,
                authodId: UUID().uuidString,
                dateCreated: .now
            ),
            Avatar(
                avatarId: UUID().uuidString,
                name: "Delta",
                character: .woman,
                action: .dancing,
                location: .forest,
                profileImageUrl: Constants.randomImageUrl,
                authodId: UUID().uuidString,
                dateCreated: .now
            )
        ]
    }
}
