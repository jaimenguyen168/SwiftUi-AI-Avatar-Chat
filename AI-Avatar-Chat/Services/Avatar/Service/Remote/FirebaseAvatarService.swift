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
            .order(by: Avatar.CodingKeys.viewCount.rawValue, descending: true)
            .limit(to: 50)
            .getAllDocuments()
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
            .order(by: Avatar.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
//            .sorted(by: {$0.dateCreated > $1.dateCreated})
    }
    
    func removeAuthorIdFromAvatar(_ avatarId: String) async throws {
        try await collection
            .document(avatarId)
            .updateData([
                Avatar.CodingKeys.authodId.rawValue: NSNull()
            ])
    }
    
    func removeAuthorIdFromAllAvatars(authorId: String) async throws {
        let avatars = try await getAvatarsForAuthor(authorId: authorId)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for avatar in avatars {
                group.addTask {
                    try await removeAuthorIdFromAvatar(avatar.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func getAvatar(id: String) async throws -> Avatar {
        try await collection
            .getDocument(id: id)
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collection
            .document(avatarId)
            .updateData([
                Avatar.CodingKeys.viewCount.rawValue: FieldValue.increment(Int64(1))
            ])
    }
}
