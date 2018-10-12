//
//  WalletType.swift
//  Wallet
//
//  Created by Cake Technologies 23.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

enum WalletType: Int {
    case bitcoin
    case monero
    case haven
    case none
    
    func stringify() -> String {
        switch self {
        case .bitcoin:
            return "Bitcoin"
        case .monero:
            return "Monero"
        case .haven:
            return "Haven Protocol"
        case .none:
            return "Invalid wallet type"
        }
    }
}
