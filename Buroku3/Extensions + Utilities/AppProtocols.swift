//
//  AppProtocols.swift
//  Buroku3
//
//  Created by J C on 2021-03-17.
//

import UIKit

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

// MARK: - HandleError
protocol HandleError {
    var alert: Alerts { get set }
    func processFailure(_ error: PostingError)
}

extension HandleError where Self: UIViewController {
    // MARK: - processFailure
    func processFailure(_ error: PostingError) {
        switch error {
            case .retrievingEstimatedGasError:
                self.alert.showDetail("Error", with: "There was an error retrieving the gas estimation.", for: self)
            case .retrievingGasPriceError:
                self.alert.showDetail("Error", with: "There was an error retrieving the current gas price.", for: self)
            case .contractLoadingError:
                self.alert.showDetail("Error", with: "There was an error loading your contract ABI.", for: self)
            case .retrievingCurrentAddressError:
                self.alert.showDetail("Account Retrieval Error", with: "Error retrieving your account address. Please ensure that you're logged into your wallet.", for: self)
            case .createTransactionIssue:
                self.alert.showDetail("Error", with: "There was an error creating a transaction.", for: self)
            case .insufficientFund(let msg):
                self.alert.showDetail("Error", with: msg, height: 500, fieldViewHeight: 300, alignment: .left, for: self)
            case .emptyAmount:
                self.alert.showDetail("Error", with: "The ETH value cannot be blank for the transaction.", for: self)
            case .invalidAmountFormat:
                self.alert.showDetail("Error", with: "The ETH value is in an incorrect format.", for: self)
            case .generalError(reason: let msg):
                self.alert.showDetail("Error", with: msg, for: self)
            default:
                self.alert.showDetail("Error", with: "There was an error creating your post.", for: self)
        }
    }
}
