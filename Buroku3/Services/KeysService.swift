//
//  KeysService.swift
//  Buroku3
//
//  Created by J C on 2021-03-18.
//

import UIKit
import web3swift

struct KeyWalletModel {
    let address: String
    let data: Data?
    
    static func fromCoreData(crModel: KeyWallet) -> KeyWalletModel {
        let model = KeyWalletModel(address: crModel.address!, data: crModel.data!)
        return model
    }
}

class KeysService: IKeysService {
    let localStorage = LocalDatabase()
    
    func selectedWallet() -> KeyWalletModel? {
        return localStorage.getWallet()
    }
    
    func addNewWalletWithPrivateKey(key: String, password: String, completion: @escaping (KeyWalletModel?, Error?) -> Void) {
        let text = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: password) else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        
        guard newWallet.addresses?.count == 1 else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        
        guard let keyData = try? JSONEncoder().encode(newWallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        
        guard let address = newWallet.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        
        let walletModel = KeyWalletModel(address: address, data: keyData)
        completion(walletModel, nil)
    }
    
    func createNewWallet(password: String, completion: @escaping (KeyWalletModel?, Error?) -> Void) {
        guard let newWallet = try? EthereumKeystoreV3(password: password) else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        
        guard newWallet.addresses?.count == 1 else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        
        guard let keydata = try? JSONEncoder().encode(newWallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        
        guard let address = newWallet.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        
        let walletModel = KeyWalletModel(address: address, data: keydata)
        completion(walletModel, nil)
    }

    func getWalletPrivateKey(password: String) throws -> String? {
        guard let selectedWallet = selectedWallet(), let address = EthereumAddress(selectedWallet.address) else {
            print(WalletSavingError.couldNotGetAddress)
            return nil
        }
        let data = try keystoreManager()?.UNSAFE_getPrivateKeyData(password: password, account: address)
        return data?.toHexString()
    }
}

protocol IKeysService {
    func keystoreManager() -> KeystoreManager?
    func selectedWallet() -> KeyWalletModel?
}

extension IKeysService {
    func keystoreManager() -> KeystoreManager? {
        guard let selectedWallet = selectedWallet(), let data = selectedWallet.data else {
            return KeystoreManager.defaultManager
        }
        return KeystoreManager([EthereumKeystoreV3(data)!])
    }
}
