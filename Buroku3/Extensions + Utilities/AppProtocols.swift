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

// MARK: - StoreObserverDelegate
protocol StoreObserverDelegate: AnyObject {
    /// Tells the delegate that the restore operation was successful.
    func storeObserverRestoreDidSucceed()
    
    /// Provides the delegate with messages.
    func storeObserverDidReceiveMessage(_ message: String)
}

// MARK: - DiscloseView
protocol DiscloseView {
    func show()
    func hide()
}

// MARK: - EnableItem
protocol EnableItem {
    func enable()
    func disable()
}

// MARK: - StoreManagerDelegate
protocol StoreManagerDelegate: AnyObject {
    /// Provides the delegate with the App Store's response.
    func storeManagerDidReceiveResponse(_ response: [Section])
    
    /// Provides the delegate with the error encountered during the product request.
    func storeManagerDidReceiveMessage(_ message: String)
}

// MARK: - SettingsDelegate
protocol SettingsDelegate: AnyObject {
    /// Tells the delegate that the user has requested the restoration of their purchases.
    func settingDidSelectRestore()
}
