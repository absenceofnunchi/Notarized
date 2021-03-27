//
//  TransactionModel+CoreDataProperties.swift
//  Buroku3
//
//  Created by J C on 2021-03-26.
//
//

import Foundation
import CoreData


extension TransactionModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionModel> {
        return NSFetchRequest<TransactionModel>(entityName: "TransactionModel")
    }

    @NSManaged public var date: Date?
    @NSManaged public var gasLimit: String?
    @NSManaged public var gasPrice: String?
    @NSManaged public var nonce: String?
    @NSManaged public var toAddress: String?
    @NSManaged public var value: String?

}

extension TransactionModel : Identifiable {

}
