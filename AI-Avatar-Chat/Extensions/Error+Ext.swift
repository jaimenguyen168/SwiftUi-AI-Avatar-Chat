//
//  Error+Ext.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 2/18/25.
//

import Foundation

extension Error {
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
