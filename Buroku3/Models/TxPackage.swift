//
//  TxPackage.swift
//  Buroku3
//
//  Created by J C on 2022-01-14.
//

import Foundation
import web3swift
import BigInt

struct TxPackage {
    let transaction: WriteTransaction
    let gasEstimate: BigUInt
    let price: String?
    var nonce: BigUInt? = nil
}
