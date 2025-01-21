//
//  AvatarEntity.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI
import SwiftData

@Model
class AvatarEntity {
    
    @Attribute(.unique) var avatarId: String
    var name: String?
    var character: Character?
    var action: Action?
    var location: Location?
    var profileImageUrl: String?
    var authodId: String?
    var dateCreated: Date
    var viewCount: Int?
    
    var dateAdded: Date
    
    init(from model: Avatar) {
        self.avatarId = model.avatarId
        self.name = model.name
        self.character = model.character
        self.action = model.action
        self.location = model.location
        self.profileImageUrl = model.profileImageUrl
        self.authodId = model.authodId
        self.dateCreated = model.dateCreated
        self.viewCount = model.viewCount
        
        self.dateAdded = .now
    }
    
    func toModel() -> Avatar {
        Avatar(
            avatarId: avatarId,
            name: name,
            character: character,
            action: action,
            location: location,
            profileImageUrl: profileImageUrl,
            authodId: authodId,
            dateCreated: dateCreated,
            viewCount: viewCount
        )
    }
}
