//
//  StoredHolding.swift
//  CodeForge Crypto
//
//  Created by Ethan on 6/5/2025.
//
import SwiftUI

struct StoredHolding: Codable, Identifiable {
    var id: String { coinID }
    let coinID: String
    let coinName: String
    var amount: Double
}
