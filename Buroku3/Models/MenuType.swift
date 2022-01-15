//
//  MenuType.swift
//  Buroku3
//
//  Created by J C on 2021-03-19.
//

import UIKit

struct Menu {
    let symbol: UIImage?
    let title: String
}

enum MenuType: Int {
    case browse
    case files
    case wallet
    case etherscan
    case transactionHistory
    case terms
    
    var VCType: UIViewController.Type {
        switch self {
            case .browse:
                return MainViewController.self
            case .files:
                return FilesViewController.self
            case .wallet:
                return WalletViewController.self
            case .etherscan, .terms:
                return WebViewController.self
            case .transactionHistory:
                return TransactionHistoryViewController.self
        }
    }
}
