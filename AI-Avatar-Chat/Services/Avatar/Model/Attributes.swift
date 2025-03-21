//
//  Character.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/3/25.
//

import Foundation

enum Character: String, Hashable, CaseIterable, Identifiable, Codable {
    case man, woman, alien, robot, dog, cat, bird, dinasour
    
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
        case .bird: "birds"
        case .dinasour: "dinosaures"
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
    case smiling, siting, waving, swimming, flying, running, eating, drinking, sleeping, working, dancing, relaxing
    
    static var `default`: Self { .dancing }
    
    var id: String { self.rawValue }
}

enum Location: String, CaseIterable, Hashable, Identifiable, Codable {
    case home, office, school, playground, park, beach, desert, museum, space, library, forest
    
    static var `default`: Self { .office }
    
    var id: String { self.rawValue }
}

struct AvatarDescriptionBuilder: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case character, action, location
    }
    
    var eventParameters: [String: Any] {
        [
            "character_\(CodingKeys.character.rawValue)": character,
            "character_\(CodingKeys.action.rawValue)": action,
            "character_\(CodingKeys.location.rawValue)": location,
            "character_description": description
        ]
    }
}
