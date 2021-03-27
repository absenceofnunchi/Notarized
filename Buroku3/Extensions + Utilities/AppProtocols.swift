//
//  AppProtocols.swift
//  Buroku3
//
//  Created by J C on 2021-03-17.
//

import Foundation

// MARK: - Custom tab bar delegate
protocol CustomTabBarDelegate: AnyObject {
    func tabBarDidSelect(with tag: Int)
}

// MARK: - Wallet delegate
protocol WalletDelegate: AnyObject {
    func didProcessWallet()
}

// MARK: - Scanner delegate
protocol ScannerDelegate: AnyObject {
    func scannerDidOutput(code: String)
}
