//
//  UserAuthInfo.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 1/11/25.
//

import SwiftUI

struct UserAuthInfo: Sendable, Codable {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }
    
    static func mock(isAnonymous: Bool = false) -> Self {
        .init(
            uid: "mockUser1",
            email: "jaime@gmail.com",
            isAnonymous: isAnonymous,
            creationDate: .now,
            lastSignInDate: .now
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "uAuth_\(CodingKeys.uid.rawValue)": uid,
            "uAuth_\(CodingKeys.email.rawValue)": email,
            "uAuth_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "uAuth_\(CodingKeys.creationDate.rawValue)": creationDate,
            "uAuth_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate
        ]
        
        return dict.compactMapValues { $0 } // drop values if nil
    }
}
