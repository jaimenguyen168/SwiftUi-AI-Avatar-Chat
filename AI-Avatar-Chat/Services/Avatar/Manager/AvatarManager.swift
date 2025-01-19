//
//  AvatarManager.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/18/25.
//

import SwiftUI
import FirebaseFirestore

protocol AvatarService: Sendable {
    func createAvatar(_ avatar: Avatar, image: UIImage) async throws
}

struct MockAvatarService: AvatarService {
    func createAvatar(_ avatar: Avatar, image: UIImage) async throws {
        
    }
}

struct FirebaseAvatarService: AvatarService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatar(_ avatar: Avatar, image: UIImage) async throws {
        let path = "avatars/\(avatar.id)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        var avatar = avatar
        avatar.updateProfileImage(image: url.absoluteString)
        
        try collection.document(avatar.id).setData(from: avatar, merge: true)
    }
}

@MainActor
@Observable
class AvatarManager {
    private let service: AvatarService
    
    init(avatarService: AvatarService) {
        self.service = avatarService
    }
    
    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        do {
            try await service.createAvatar(avatar, image: image)
        } catch {
            print("Error creating avatar: \(error)")
        }
    }
}
