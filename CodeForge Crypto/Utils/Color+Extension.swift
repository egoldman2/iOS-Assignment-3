//
//  Color+Extension.swift
//  CodeForge Crypto
//
//  Created by Ethan on 12/5/2025.
//

import SwiftUI

// Extension to allow Color initialization from a hexadecimal string.
extension Color {
    static func hex(_ hex: String) -> Color {
        // Remove any non-alphanumeric characters from the input string
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        
        // Handle 3-digit RGB, 6-digit RGB, and 8-digit ARGB hex formats
        switch hex.count {
        case 3: // RGB (12-bit, shorthand notation)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: // Fallback to transparent black for invalid input
            (a, r, g, b) = (1, 1, 1, 0)
        }

        // Return a Color using the normalized sRGB values
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
