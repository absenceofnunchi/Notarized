//
//  Web3swiftService.swift
//  Buroku3
//
//  Created by J C on 2021-03-19.
//

import Foundation
import web3swift
import BigInt

class Web3swiftService {
    static let keyservice = KeysService()
    
//    static var web3instance: web3 {
//        let web3 = Web3.InfuraMainnetWeb3()
//        web3.addKeystoreManager(self.keyservice.keystoreManager())
//        return web3
//    }
    
    static var web3instance: web3 {
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        web3Rinkeby.addKeystoreManager(self.keyservice.keystoreManager())
        return web3Rinkeby
    }
    
    static var currentAddress: EthereumAddress? {
        let wallet = self.keyservice.selectedWallet()
        guard let address = wallet?.address else {
            return nil
        }
        let ethAddressFrom =  EthereumAddress(address)
        return ethAddressFrom
    }
    
    func isEthAddressValid(address: String) -> Bool {
        if EthereumAddress(address) != nil {
            return true
        }
        
        return false
    }
    
}

extension Web3swiftService {
    // MARK: - Upload file
    
    func uploadFile(completion: @escaping ([String: Any]) -> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethAddressTo = EthereumAddress(contractAddress) else {
            print("invalid eth contract address")
            return
        }
        
        DispatchQueue.global().async {
            let web3 = Web3swiftService.web3instance
            guard let contract = web3.contract(someABI, at: ethAddressTo, abiVersion: 2) else {
                return
            }
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethAddressTo
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.method("uploadFile", transactionOptions: options) else {
                print("upload file contract method creation error")
                return
            }
            
            do {
                let result = try transaction.call(transactionOptions: options)
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                print("upload file contract method call error", error)
            }
        }
        
    }
    
    // MARK: - Access file
    
    func accessFile(completion: @escaping ([String: Any]) -> Void) {
        let ethAddressFrom = Web3swiftService.currentAddress
        guard let ethAddressTo = EthereumAddress(contractAddress) else {
            print("invalid eth contract address")
            return
        }
        
        DispatchQueue.global().async {
            let web3 = Web3swiftService.web3instance
            guard let contract = web3.contract(someABI, at: ethAddressTo, abiVersion: 2) else {
                return
            }
            
            var options = TransactionOptions.defaultOptions
            options.from = ethAddressFrom
            options.to = ethAddressTo
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            contract.transactionOptions = options
            guard let transaction = contract.method("accessFile", transactionOptions: options) else {
                print("access file contract method creation error")
                return
            }
            
            do {
                let result = try transaction.call(transactionOptions: options)
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                print("access file contract method call error", error)
            }
        }
        
    }
}
