//
//  Color+Ext.swift
//  AI-Avatar-Chat
//
//  Created by Dat Nguyen on 12/23/24.
//

import Foundation
import SwiftUI

extension Color {
    static func fromHex(_ hex: String) -> Color? {
        let r, g, b, a: Double // swiftlint:disable:this identifier_name
                
        var sanitizedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove "#" if present
        if sanitizedHex.hasPrefix("#") {
            sanitizedHex.removeFirst()
        }
        
        // Validate hex string length (must be 6 or 8)
        guard sanitizedHex.count == 6 || sanitizedHex.count == 8 else {
            return nil
        }
        
        var hexValue: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&hexValue)
        
        if sanitizedHex.count == 6 {
            r = Double((hexValue & 0xFF0000) >> 16) / 255
            g = Double((hexValue & 0x00FF00) >> 8) / 255
            b = Double(hexValue & 0x0000FF) / 255
            a = 1.0
        } else {
            r = Double((hexValue & 0xFF000000) >> 24) / 255
            g = Double((hexValue & 0x00FF0000) >> 16) / 255
            b = Double((hexValue & 0x0000FF00) >> 8) / 255
            a = Double(hexValue & 0x000000FF) / 255
        }
        
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
    
    func asHex(alpha: Bool = false) -> String {
        // Convert Color to UIColor
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alphaValue: CGFloat = 0

        // Use guard to ensure all components can be extracted
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alphaValue) else {
            // Return a default color (black or transparent) if unable to extract components
            return alpha ? "#00000000": "#000000"
        }

        if alpha {
            // Include alpha component in the hex string
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(Float(alphaValue) * 255),
                          lroundf(Float(red) * 255),
                          lroundf(Float(green) * 255),
                          lroundf(Float(blue) * 255))
        } else {
            // Exclude alpha component from the hex string
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(Float(red) * 255),
                          lroundf(Float(green) * 255),
                          lroundf(Float(blue) * 255))
        }
    }
}
