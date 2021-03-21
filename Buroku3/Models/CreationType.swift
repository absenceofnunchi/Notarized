//
//  CreationType.swift
//  Buroku3
//
//  Created by J C on 2021-03-19.
//

import Foundation

enum WalletCreationType {
    case importKey
    case createKey
    
    func title() -> String {
        switch self {
            case .importKey:
                return "Import Wallet"
            case .createKey:
                return "Create Wallet"
        }
    }
}
