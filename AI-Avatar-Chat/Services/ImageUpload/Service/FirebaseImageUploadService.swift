//
//  FirebaseImageUploadService.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/18/25.
//

import FirebaseStorage
import SwiftUI

protocol ImageUploadService {
    func uploadImage(image: UIImage, path: String) async throws -> URL
}

struct FirebaseImageUploadService {
    
    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.dataNotAllowed)
        }
        
        // upload
        let _ = try await saveImage(data: data, path: path)
        
        // download url
        return try await imageReference(path: path).downloadURL()
    }
    
    private func imageReference(path: String) -> StorageReference {
        let name = "\(path).jpg"
        return Storage.storage().reference(withPath: name)
    }
    
    private func saveImage(data: Data, path: String) async throws -> URL {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let info = try await imageReference(path: path).putDataAsync(data, metadata: metadata)
        
        guard let returnPath = info.path, let url = URL(string: returnPath) else {
            throw URLError(.badServerResponse)
        }
        
        return url
    }
}
