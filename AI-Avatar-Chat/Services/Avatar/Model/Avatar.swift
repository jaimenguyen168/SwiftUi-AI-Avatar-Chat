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

enum Character: String, Hashable, CaseIterable, Identifiable {
    case man, woman, alien, robot, dog, cat
    
    static var `default`: Self { .alien }
    
    var id: String { self.rawValue }
    
    var startsWithVowel: Bool {
        guard let firstLetter = self.rawValue.first?.lowercased() else {
            return false
        }
        return ["a", "e", "i", "o", "u"].contains(firstLetter)
    }
}

enum Action: String {
    case smiling, siting, waving, running, eating, drinking, sleeping, working, dancing, relaxing
    
    static var `default`: Self { .dancing }
}

enum Location: String {
    case home, office, school, playground, park, beach, desert, museum, space, library, forest
    
    static var `default`: Self { .office }
}

struct AvatarDescriptionBuilder {
    let character: Character
    let action: Action
    let location: Location
    
    init(character: Character, action: Action, location: Location) {
        self.character = character
        self.action = action
        self.location = location
    }
    
    init(avatar: Avatar) {
        self.character = avatar.character ?? .default
        self.action = avatar.action ?? .default
        self.location = avatar.location ?? .default
    }
    
    var description: String {
        "\(character.startsWithVowel ? "An" : "A") \(character.rawValue) is \(action.rawValue) in the \(location.rawValue)"
    }
}
