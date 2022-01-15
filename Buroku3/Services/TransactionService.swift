//
//  TransactionService.swift
//  Buroku3
//
//  Created by J C on 2021-03-25.
//

import Foundation
import web3swift
import BigInt
import Combine

class TransactionService {
    let keysService = KeysService()
    var storage = Set<AnyCancellable>()
    
    final func requestGasPrice(onComplition:@escaping (Double?) -> Void) {
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
    final func stripZeros(_ string: String) -> String {
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
    final func prepareTransactionForSending(destinationAddressString: String?,
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
//    final func prepareTransactionForNewContract(completion: @escaping (WriteTransaction?, Error?) -> Void) {
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
    final func prepareTransactionForSettingFile(
        _ method: ContractMethods,
        parameters: [AnyObject],
        completion: @escaping (WriteTransaction?, SendEthErrors?) -> Void
    ) {
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
        
        guard let transaction = contract.write(method.rawValue, parameters: parameters, extraData: Data(), transactionOptions: options) else {
            DispatchQueue.main.async {
                completion(nil, SendEthErrors.createTransactionIssue)
            }
            return
        }
        
        DispatchQueue.main.async {
            completion(transaction, nil)
        }
    }
    
    // Combine's version of transaction preparation for setting files on the blockchain
    final func prepareTransactionForSettingFile(
        _ method: ContractMethods,
        parameters: [AnyObject],
        promise: @escaping (Result<TxPackage, PostingError>) -> Void
    ) {
        guard let address = Web3swiftService.currentAddress else { return }
        var options = TransactionOptions.defaultOptions
        options.from = address
        options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
        options.gasPrice = TransactionOptions.GasPricePolicy.automatic
        
        let web3 = Web3swiftService.web3instance
        guard let contract = web3.contract(fileManagerABI, at: fileManagerContractAddress, abiVersion: 2) else {
            promise(.failure(.contractLoadingError))
            return
        }
        
        print("method.rawValue", method.rawValue)
        guard let transaction = contract.write(method.rawValue, parameters: parameters, extraData: Data(), transactionOptions: options) else {
            promise(.failure(.createTransactionIssue))
            return
        }
        
        do {
            let gasEstimate = try transaction.estimateGas()
            let txPackage = TxPackage(transaction: transaction, gasEstimate: gasEstimate, price: nil)
            promise(.success(txPackage))
        } catch {
            promise(.failure(.retrievingEstimatedGasError))
        }
    }
    
    // MARK: - prepareTransactionFiles
    final func prepareTransactionForFiles(method: String, parameters: [AnyObject] = [AnyObject](), completion: @escaping (ReadTransaction?, SendEthErrors?) -> Void) {
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
    
    final func prepareTransactionForDeletingFiles(method: String, parameters: [AnyObject] = [AnyObject](), completion: @escaping (WriteTransaction?, SendEthErrors?) -> Void) {
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
    
    final func prepareTransactionForWritingWithGasEstimate(
        method: String,
        abi: String,
        param: [AnyObject] = [AnyObject](),
        contractAddress: EthereumAddress,
        amountString: String?,
        to: EthereumAddress? = nil,
        promise: @escaping (Result<TxPackage, PostingError>) -> Void
    ) {
        self.prepareTransactionForWriting(
            method: method,
            abi: abi,
            param: param,
            contractAddress: contractAddress,
            to: to,
            amountString: amountString
        ) { (transaction, error) in
            if let error = error {
                promise(.failure(error))
            }
            
            if let transaction = transaction {
                do {
                    let gasEstimate = try transaction.estimateGas()
                    let txPackage = TxPackage(
                        transaction: transaction,
                        gasEstimate: gasEstimate,
                        price: nil
                    )
                    
                    promise(.success(txPackage))
                } catch {
                    promise(.failure(.retrievingEstimatedGasError))
                }
            }
        }
    }
    
    final func prepareTransactionForWriting(
        method: String,
        abi: String,
        param: [AnyObject] = [AnyObject](),
        contractAddress: EthereumAddress,
        amountString: String?,
        to: EthereumAddress? = nil,
        promise: @escaping (Result<WriteTransaction, PostingError>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let web3 = Web3swiftService.web3instance
            guard let fromAddress = Web3swiftService.currentAddress else {
                promise(.failure(PostingError.generalError(reason: "Could not retrieve the wallet address.")))
                return
            }
            
            var options = TransactionOptions.defaultOptions
            options.from = fromAddress
            
            if amountString != nil {
                guard let amount = Web3.Utils.parseToBigUInt(amountString!, units: .eth) else {
                    promise(.failure(PostingError.invalidAmountFormat))
                    return
                }
                
                options.value = amount
            }
            
            //            options.to = to
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            
            guard let contract = web3.contract(abi, at: contractAddress, abiVersion: 2) else {
                promise(.failure(PostingError.contractLoadingError))
                return
            }
            
            guard let transaction = contract.write(
                method,
                parameters: param,
                extraData: Data(),
                transactionOptions: options
            ) else {
                promise(.failure(PostingError.createTransactionIssue))
                return
            }
            
            promise(.success(transaction))
        }
    }
    
    final func prepareTransactionForWriting(
        method: String,
        abi: String,
        param: [AnyObject] = [AnyObject](),
        contractAddress: EthereumAddress,
        to: EthereumAddress? = nil,
        amountString: String?,
        completion: @escaping (WriteTransaction?, PostingError?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let web3 = Web3swiftService.web3instance
            guard let myAddress = Web3swiftService.currentAddress else {
                completion(nil, PostingError.retrievingCurrentAddressError)
                return
            }
            
            var options = TransactionOptions.defaultOptions
            
            if let amountString = amountString {
                guard !amountString.isEmpty else {
                    completion(nil, PostingError.emptyAmount)
                    return
                }
                
                guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
                    completion(nil, PostingError.invalidAmountFormat)
                    return
                }
                
                options.value = amount
            }
            
            if let to = to {
                options.to = to
            }
            
            options.from = myAddress
            options.gasLimit = TransactionOptions.GasLimitPolicy.automatic
            options.gasPrice = TransactionOptions.GasPricePolicy.automatic
            
            guard let contract = web3.contract(abi, at: contractAddress, abiVersion: 2) else {
                completion(nil, PostingError.contractLoadingError)
                return
            }
            
            guard let transaction = contract.write(
                method,
                parameters: param,
                extraData: Data(),
                transactionOptions: options
            ) else {
                completion(nil, PostingError.createTransactionIssue)
                return
            }
            
            completion(transaction, nil)
        }
    }
    
    // MARK: - prelaunch
    /// Estimate the total gas fee in the format that the execution completion handler can understand with the transaction of any kind provided as a parameter
    final func preLaunch(
        // mintParameters: MintParameters,
        transactionToEstimate: @escaping () -> AnyPublisher<TxPackage, PostingError>,
        completionHandler: @escaping ((totalGasCost: String, balance: String, gasPriceInGwei: String)?, TxPackage?, PostingError?) -> Void
    ) {
        
        var txPackageRetainer: TxPackage!
        
        transactionToEstimate()
            .flatMap({ [weak self] (txPackage) -> AnyPublisher<(totalGasCost: String, balance: String, gasPriceInGwei: String), PostingError> in
                txPackageRetainer = txPackage
                return Future<(totalGasCost: String, balance: String, gasPriceInGwei: String), PostingError> { promise in
                    self?.estimateGas(
                        gasEstimate: txPackage.gasEstimate,
                        promise: promise
                    )
                }
                .eraseToAnyPublisher()
            })
            .sink { (completion) in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        completionHandler(nil, nil, error)
                        break
                }
            } receiveValue: { (estimates) in
                completionHandler(estimates, txPackageRetainer, nil)
            }
            .store(in: &self.storage)
    }
    
    final func estimateGas(
        gasEstimate: BigUInt,
        promise: @escaping (Result<(totalGasCost: String, balance: String, gasPriceInGwei: String), PostingError>) -> Void
    )  {
        var gasPrice: BigUInt!
        do {
            gasPrice = try Web3swiftService.web3instance.eth.getGasPrice()
        } catch {
            promise(.failure(.generalError(reason: "Unable to fetch the current gas price. Please try again later.")))
            return
        }
        
        let totalGasCost = gasEstimate * gasPrice
        
        guard let convertedTotalGasCost = Web3.Utils.formatToEthereumUnits(totalGasCost, toUnits: .eth, decimals: 9) else {
            promise(.failure(.generalError(reason: "Unable to convert the unit of the gas cost. Please try restarting the app.")))
            return
        }
        
        let trimmedTotalGasCost = stripZeros(convertedTotalGasCost)
        
        var balance: BigUInt!
        do {
            balance = try Web3swiftService.web3instance.eth.getBalance(address: Web3swiftService.currentAddress!)
        } catch {
            promise(.failure(.generalError(reason:  "Unable to retrieve the balance of your wallet. Please try restarting the app.")))
            return
        }
        
        guard let convertedBalance = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth) else {
            promise(.failure(.generalError(reason:  "Unable to convert the unit of your wallet balance. Please try restarting the app.")))
            return
        }
        
        guard let gasPriceInGwei = Web3.Utils.formatToEthereumUnits(gasPrice, toUnits: .Gwei) else {
            promise(.failure(.generalError(reason:  "Unable to convert the unit of the gas price. Please try restarting the app.")))
            return
        }
        
        promise(.success((trimmedTotalGasCost, convertedBalance, gasPriceInGwei)))
    }
}


enum SendEthResult<T> {
    case Success(T)
    case Error(Error)
}
