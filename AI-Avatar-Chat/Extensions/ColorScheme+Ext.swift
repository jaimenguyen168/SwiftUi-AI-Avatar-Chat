//
//  ColorScheme+Ext.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 3/1/25.
//

import SwiftUI

extension ColorScheme {
    var backgroundPrimary: Color {
        self == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground)
    }
    
    var backgroundSecondary: Color {
        self == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground)
    }

}
