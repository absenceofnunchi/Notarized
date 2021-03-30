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
    
    static var web3instance: web3 {
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        web3Rinkeby.addKeystoreManager(self.keyservice.keystoreManager())
        return web3Rinkeby
    }
    
//    static var web3instance: web3 {
//        let web3Ropsten = Web3.InfuraRopstenWeb3()
//        web3Ropsten.addKeystoreManager(self.keyservice.keystoreManager())
//        return web3Ropsten
//    }
    
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
