//
//  SwiftDataLocalAvatarPersistence.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/20/25.
//

import SwiftUI
import SwiftData

@MainActor
struct SwiftDataLocalAvatarPersistence: LocalAvatarPersistence {
    private let container: ModelContainer
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: AvatarEntity.self)
    }
    
    func addRecentAvatar(_ avatar: Avatar) throws {
        let entity = AvatarEntity(from: avatar)
        
        mainContext.insert(entity)
        try mainContext.save()
    }
    
    func getRecentAvatars() throws -> [Avatar] {
        let descriptor = FetchDescriptor<AvatarEntity>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map({ $0.toModel() })
    }
    
    func removeAllRecentAvatars() throws {
        let descriptor = FetchDescriptor<AvatarEntity>()
        let entities = try mainContext.fetch(descriptor)
        for entity in entities {
            mainContext.delete(entity)
        }
        try mainContext.save()
    }
}
