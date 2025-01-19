//
//  Character.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/3/25.
//

import Foundation

enum Character: String, Hashable, CaseIterable, Identifiable, Codable {
    case man, woman, alien, robot, dog, cat
    
    static var `default`: Self { .alien }
    
    var id: String { self.rawValue }
    
    var plural: String {
        switch self {
        case .man: "men"
        case .woman: "women"
        case .alien: "aliens"
        case .robot: "robots"
        case .dog: "dogs"
        case .cat: "cats"
        }
    }
    
    var startsWithVowel: Bool {
        guard let firstLetter = self.rawValue.first?.lowercased() else {
            return false
        }
        return ["a", "e", "i", "o", "u"].contains(firstLetter)
    }
}

enum Action: String, CaseIterable, Hashable, Identifiable, Codable {
    case smiling, siting, waving, running, eating, drinking, sleeping, working, dancing, relaxing
    
    static var `default`: Self { .dancing }
    
    var id: String { self.rawValue }
}

enum Location: String, CaseIterable, Hashable, Identifiable, Codable {
    case home, office, school, playground, park, beach, desert, museum, space, library, forest
    
    static var `default`: Self { .office }
    
    var id: String { self.rawValue }
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
