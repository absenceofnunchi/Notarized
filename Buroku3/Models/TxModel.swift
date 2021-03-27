//
//  TxModel.swift
//  Buroku3
//
//  Created by J C on 2021-03-26.
//

import Foundation

struct TxModel {
    let gasPrice: String
    let gasLimit: String
    let toAddress: String
    let value: String
    let date: Date
    let nonce: String
    
    static func fromCoreData(crModel: TransactionModel) -> TxModel {
        let tx = TxModel(gasPrice: crModel.gasPrice!, gasLimit: crModel.gasLimit!, toAddress: crModel.toAddress!, value: crModel.value!, date: crModel.date!, nonce: crModel.nonce!)
        return tx
    }
}
