//
//  FirebaseAvatarService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI
import FirebaseFirestore

struct FirebaseAvatarService: RemoteAvatarService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatar(_ avatar: Avatar, image: UIImage) async throws {
        let path = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        var avatar = avatar
        avatar.updateProfileImage(image: url.absoluteString)
        
        try collection.document(avatar.avatarId).setData(from: avatar, merge: true)
    }
    
    func getFeaturedAvatars() async throws -> [Avatar] {
        try await collection
            .limit(to: 50)
            .getAllDocuments()
            .shuffled()
            .first(upTo: 5) ?? []
    }
    
    func getPopularAvatars() async throws -> [Avatar] {
        try await collection
            .limit(to: 200)
            .getAllDocuments()
            .first(upTo: 5) ?? []
    }
    
    func getAvatarsForCategory(category: Character) async throws -> [Avatar] {
        try await collection
            .whereField(Avatar.CodingKeys.character.rawValue, isEqualTo: category.rawValue)
            .limit(to: 100)
            .getAllDocuments()
    }
    
    func getAvatarsForAuthor(authorId: String) async throws -> [Avatar] {
        try await collection
            .whereField(Avatar.CodingKeys.authodId.rawValue, isEqualTo: authorId)
            .limit(to: 100)
            .getAllDocuments()
    }
    
    func getAvatar(id: String) async throws -> Avatar {
        try await collection
            .getDocument(id: id)
    }
}
