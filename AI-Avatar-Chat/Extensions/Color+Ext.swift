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
    
    func toHex(includeAlpha: Bool = false) -> String? {
        let components = self.cgColor?.components
        let r, g, b, a: Int // swiftlint:disable:this identifier_name
        
        guard let components = components else { return nil }
        
        r = Int(components[0] * 255)
        g = Int(components[1] * 255)
        b = Int(components[2] * 255)
        a = components.count >= 4 ? Int(components[3] * 255) : 255
        
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }
    
//    func toHex(includeAlpha: Bool = false) -> String? {
//        let uiColor = UIColor(self) // Convert Color to UIColor
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//        let r, g, b, a: Int // swiftlint:disable:this identifier_name
//        
//        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
//            return nil
//        }
//        
//        r = Int(red * 255)
//        g = Int(green * 255)
//        b = Int(blue * 255)
//        a = Int(alpha * 255)
//        
//        if includeAlpha {
//            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
//        } else {
//            return String(format: "#%02X%02X%02X", r, g, b)
//        }
//    }
}
