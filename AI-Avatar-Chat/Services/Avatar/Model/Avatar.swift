//
//  Avatar.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/20/24.
//

import Foundation
import IdentifiableByString

struct Avatar: Hashable, Codable, StringIdentifiable {
    let id: String
    
    var avatarId: String { id }
    let name: String?
    let character: Character?
    let action: Action?
    let location: Location?
    private(set) var profileImageUrl: String?
    
    let authodId: String?
    let dateCreated: Date
    
    let viewCount: Int?
    
    var description: String {
        AvatarDescriptionBuilder(avatar: self).description
    }
    
    static func aiDescription(_ avatar: Avatar) -> String {
        "My name is \(avatar.name ?? "an avatar"), a/an \(avatar.description) with the intelligence of an AI. We are having a very casual conversation. You are my friend."
    }
    
    init(
        avatarId: String,
        name: String? = nil,
        character: Character? = nil,
        action: Action? = nil,
        location: Location? = nil,
        profileImageUrl: String? = nil,
        authodId: String? = nil,
        dateCreated: Date = Date(),
        viewCount: Int? = nil
    ) {
        self.id = avatarId
        self.name = name
        self.character = character
        self.action = action
        self.location = location
        self.profileImageUrl = profileImageUrl
        self.authodId = authodId
        self.dateCreated = dateCreated
        self.viewCount = viewCount
    }
    
    mutating func updateProfileImage(image: String) {
        profileImageUrl = image
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "avatar_id"
        case name
        case character
        case action
        case location
        case profileImageUrl = "profile_image_url"
        case authodId = "author_id"
        case dateCreated = "date_created"
        case viewCount = "view_count"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "avatar_\(CodingKeys.id.rawValue)": avatarId,
            "avatar_\(CodingKeys.name.rawValue)": name,
            "avatar_\(CodingKeys.character.rawValue)": character?.rawValue,
            "avatar_\(CodingKeys.action.rawValue)": action?.rawValue,
            "avatar_\(CodingKeys.location.rawValue)": location?.rawValue,
            "avatar_\(CodingKeys.profileImageUrl.rawValue)": profileImageUrl,
            "avatar_\(CodingKeys.authodId.rawValue)": authodId,
            "avatar_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "avatar_\(CodingKeys.viewCount.rawValue)": viewCount
        ]
        
        return dict.compactMapValues { $0 } // drop values if nil
    }
    
    static func newAvatar(
        name: String,
        character: Character,
        action: Action,
        location: Location,
        authorId: String
    ) -> Self {
        Avatar(
            avatarId: UUID().uuidString,
            name: name,
            character: character,
            action: action,
            location: location,
            profileImageUrl: nil,
            authodId: authorId,
            dateCreated: .now,
            viewCount: 0
        )
    }
    
    static var mock: Avatar {
        mocks[0]
    }
    
    static var mocks: [Avatar] {
        [
            Avatar(
                avatarId: "mock_ava_1",
                name: "Alpha",
                character: .alien,
                action: .eating,
                location: .beach,
                profileImageUrl: Constants.randomImageUrl,
                authodId: UUID().uuidString,
                dateCreated: .now,
                viewCount: 45
            ),
            Avatar(
                avatarId: "mock_ava_2",
                name: "Beta",
                character: .dog,
                action: .smiling,
                location: .space,
                profileImageUrl: Constants.randomImageUrl,
                authodId: UUID().uuidString,
                dateCreated: .now,
                viewCount: 23
            ),
            Avatar(
                avatarId: "mock_ava_3",
                name: "Gamma",
                character: .cat,
                action: .working,
                location: .desert,
                profileImageUrl: Constants.randomImageUrl,
                authodId: UUID().uuidString,
                dateCreated: .now,
                viewCount: 78
            ),
            Avatar(
                avatarId: "mock_ava_4",
                name: "Delta",
                character: .woman,
                action: .dancing,
                location: .forest,
                profileImageUrl: Constants.randomImageUrl,
                authodId: UUID().uuidString,
                dateCreated: .now,
                viewCount: 6
            )
        ]
    }
}
