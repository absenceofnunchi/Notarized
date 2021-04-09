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
    case couldNotDeleteTheWallet
}

enum SendEthErrors: Error {
    case invalidDestinationAddress
    case invalidAmountFormat
    case emptyDestinationAddress
    case emptyAmount
    case contractLoadingError
    case retrievingGasPriceError
    case retrievingEstimatedGasError
    case emptyResult
    case noAvailableKeys
    case createTransactionIssue
    case zeroAmount
    case insufficientFund
}

enum AccountContractErrors: Error {
    case contractLoadingError
    case instantiateContractError
}

enum ResetPasswordError: Error {
    case failureToFetchOldPassword
    case failureToRegeneratePassword
}

