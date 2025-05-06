//
//  ProfileViewModel.swift
//  CodeForge Crypto
//
//  Created by Ethan on 6/5/2025.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var holdings: [Holding] = [
        Holding(coinID: StaticData[0].id, coinSymbol: StaticData[0].symbol, coinName: StaticData[0].name, amountHeld: 1.2),
        Holding(coinID: StaticData[1].id, coinSymbol: StaticData[1].symbol, coinName: StaticData[1].name, amountHeld: 0.75),
        Holding(coinID: StaticData[2].id, coinSymbol: StaticData[2].symbol, coinName: StaticData[2].name, amountHeld: 5.0)
    ]
}
