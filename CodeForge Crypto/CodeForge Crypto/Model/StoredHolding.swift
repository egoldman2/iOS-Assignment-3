//
//  StoredHolding.swift
//  CodeForge Crypto
//
//  Created by Ethan on 6/5/2025.
//


struct StoredHolding: Codable, Identifiable {
    var id: String { coinID }
    let coinID: String
    var amount: Double
}
