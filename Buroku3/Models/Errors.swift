//
//  Errors.swift
//  Buroku3
//
//  Created by J C on 2021-03-19.
//

import Foundation

enum Errors: Error {
    case noKey
    case noPassword
    case wrongPassword
}

enum WalletSavingError: Error {
    case couldNotSaveTheWallet
    case couldNotCreateTheWallet
    case couldNotGetTheWallet
    case couldNotGetAddress
    case couldNotGetThePrivateKey
}
