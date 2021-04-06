//
//  TxModel.swift
//  Buroku3
//
//  Created by J C on 2021-03-26.
//

import Foundation

struct TxModel {
    let transactionHash: String
    let fileHash: String?
    let date: Date
    let walletAddress: String
    let transactionType: String
    
    static func fromCoreData(crModel: TransactionModel) -> TxModel {
//        guard let transactionHash = crModel.transactionHash, let date = crModel.date else { return nil }
        let tx = TxModel(transactionHash: crModel.transactionHash!, fileHash: crModel.fileHash, date: crModel.date!, walletAddress: crModel.walletAddress!, transactionType: crModel.transactionType!)
        return tx
    }
}

enum TransactionType: String {
    case imageUploaded = "Image Uploaded"
    case docUploaded = "Document Uploaded"
    case etherSent = "Ether Sent"
}
