//
//  TransactionService.swift
//  Buroku3
//
//  Created by J C on 2021-03-25.
//

import Foundation
import web3swift
import BigInt
import PromiseKit

class TransactionService {
    let keysService = KeysService()

    func requestGasPrice(onComplition:@escaping (Double?) -> Void) {
        let path = "https://ethgasstation.info/json/ethgasAPI.json"
        guard let url = URL(string: path) else {
            DispatchQueue.main.async {
                onComplition(nil)
            }
            return
        }
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    onComplition(nil)
                }
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    let gasPrice = json?["average"] as? Double
                    DispatchQueue.main.async {
                        onComplition(gasPrice)
                    }
                }catch {
                    DispatchQueue.main.async {
                        onComplition(nil)
                    }
                }
            }
        }
        dataTask.resume()
    }
 
    // MARK: - stripZeros
    func stripZeros(_ string: String) -> String {
        if !string.contains(".") {return string}
        var end = string.index(string.endIndex, offsetBy: -1)
        
        while string[end] == "0" {
            end = string.index(before: end)
        }
        if string[end] == "." {
            if string[string.index(before: end)] == "0" {
                return "0.0"
            } else {
                return string[...end] + "0"
            }
        }
        return String(string[...end])
    }
    
    //MARK: - prepareTransactionForSending
    func prepareTransactionForSending(destinationAddressString: String?,
                                      amountString: String?,
                                      gasLimit: UInt = 21000,
                                      completion:  @escaping (WriteTransaction?, SendEthErrors?) -> Void) {
        guard let address = Web3swiftService.currentAddress else { return }
        var balance: BigUInt!
        
        DispatchQueue.global().async {
            balance = try? Web3swiftService.web3instance.eth.getBalance(address: address)

            guard let destinationAddressString = destinationAddressString, !destinationAddressString.isEmpty else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.emptyDestinationAddress)
                }
                return
            }
            
            guard let amountString = amountString, !amountString.isEmpty else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.emptyAmount)
                }
                return
            }
            
            guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.invalidDestinationAddress)
                }
                return
            }
            
            guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.invalidAmountFormat)
                }
                return
            }
            
            guard amount > 0 else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.zeroAmount)
                }
                return
            }
            
            guard amount <= (balance ?? 0) else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.insufficientFund)
                }
                return
            }
            
            var options = TransactionOptions.defaultOptions
            options.from = address
            options.value = BigUInt(amount)
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            
            let web3 = Web3swiftService.web3instance
            guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress, abiVersion: 2) else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.contractLoadingError)
                }
                return
            }
            
            guard let transaction = contract.write("fallback", parameters: [AnyObject](), extraData: Data(), transactionOptions: options) else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.createTransactionIssue)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(transaction, nil)
            }
        }
    }
    
    // MARK: - prepareTransactionForNewContract
//    func prepareTransactionForNewContract(completion: @escaping (WriteTransaction?, Error?) -> Void) {
//        guard let address = Web3swiftService.currentAddress else { return }
//        var options = TransactionOptions.defaultOptions
//        options.from = address
//        options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
//        options.gasPrice = TransactionOptions.GasPricePolicy.automatic
//
//        let web3 = Web3swiftService.web3instance
//        guard let contract = web3.contract(accountABI) else {
//            DispatchQueue.main.async {
//                completion(nil, AccountContractErrors.contractLoadingError)
//            }
//            return
//        }
//
//        let bytecode = Data(hex: accountBytecode)
//        guard let transaction = contract.deploy(bytecode: bytecode, parameters: [AnyObject](), extraData: Data(), transactionOptions: options) else {
//            DispatchQueue.main.async {
//                completion(nil, SendEthErrors.createTransactionIssue)
//            }
//            return
//        }
//            
//            DispatchQueue.global().async {
//                do {
//                    let result = try transaction.send(password: "11111", transactionOptions: nil)
//                    print("result", result)
//                } catch {
//                    print("error from send", error)
//                }
//            }
//        DispatchQueue.main.async {
//            completion(transaction, nil)
//        }
//    }
        
    // MARK: - prepareTransactionFiles
    func prepareTransactionForSettingFile(parameters: [AnyObject], completion: @escaping (WriteTransaction?, SendEthErrors?) -> Void) {
        guard let address = Web3swiftService.currentAddress else { return }
        var options = TransactionOptions.defaultOptions
        options.from = address
        options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
        options.gasPrice = TransactionOptions.GasPricePolicy.automatic
        
        let web3 = Web3swiftService.web3instance
        guard let contract = web3.contract(fileManagerABI, at: fileManagerContractAddress, abiVersion: 2) else {
            DispatchQueue.main.async {
                completion(nil, SendEthErrors.contractLoadingError)
            }
            return
        }
        
        guard let transaction = contract.write("setFile", parameters: parameters, extraData: Data(), transactionOptions: options) else {
            DispatchQueue.main.async {
                completion(nil, SendEthErrors.createTransactionIssue)
            }
            return
        }
        
        DispatchQueue.main.async {
            completion(transaction, nil)
        }
    }
    
    // MARK: - prepareTransactionFiles
    func prepareTransactionForFiles(method: String, parameters: [AnyObject] = [AnyObject](), completion: @escaping (ReadTransaction?, SendEthErrors?) -> Void) {
        guard let address = Web3swiftService.currentAddress else {
            DispatchQueue.main.async {
                completion(nil, SendEthErrors.noAvailableKeys)
            }
            return
        }
        var options = TransactionOptions.defaultOptions
        options.from = address
        options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
        options.gasPrice = TransactionOptions.GasPricePolicy.automatic
        
        let web3 = Web3swiftService.web3instance
        guard let contract = web3.contract(fileManagerABI, at: fileManagerContractAddress, abiVersion: 2) else {
            DispatchQueue.main.async {
                completion(nil, SendEthErrors.contractLoadingError)
            }
            return
        }
        
        guard let transaction = contract.read(method, parameters: parameters, extraData: Data(), transactionOptions: options) else {
            DispatchQueue.main.async {
                completion(nil, SendEthErrors.createTransactionIssue)
            }
            return
        }
        
        DispatchQueue.main.async {
            completion(transaction, nil)
        }
    }
    
    func prepareTransactionForDeletingFiles(method: String, parameters: [AnyObject] = [AnyObject](), completion: @escaping (WriteTransaction?, SendEthErrors?) -> Void) {
        guard let address = Web3swiftService.currentAddress else { return }
        var options = TransactionOptions.defaultOptions
        options.from = address
        options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
        options.gasPrice = TransactionOptions.GasPricePolicy.automatic
        
        DispatchQueue.global().async {
            let web3 = Web3swiftService.web3instance
            guard let contract = web3.contract(fileManagerABI, at: fileManagerContractAddress, abiVersion: 2) else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.contractLoadingError)
                }
                return
            }
            
            guard let transaction = contract.write(method, parameters: parameters, extraData: Data(), transactionOptions: options) else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.createTransactionIssue)
                }
                return
            }
            
            let balance = try? Web3swiftService.web3instance.eth.getBalance(address: address)
            guard let gasPrice = try? Web3swiftService.web3instance.eth.getGasPrice() else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.retrievingGasPriceError)
                }
                return
            }
            
            guard gasPrice < (BigUInt(balance ?? 0)) else {
                DispatchQueue.main.async {
                    completion(nil, SendEthErrors.insufficientFund)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(transaction, nil)
            }
        }
    }
}

enum SendEthResult<T> {
    case Success(T)
    case Error(Error)
}
