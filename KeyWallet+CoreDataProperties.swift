//
//  KeyWallet+CoreDataProperties.swift
//  Buroku3
//
//  Created by J C on 2021-04-01.
//
//

import Foundation
import CoreData


extension KeyWallet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeyWallet> {
        return NSFetchRequest<KeyWallet>(entityName: "KeyWallet")
    }

    @NSManaged public var address: String?
    @NSManaged public var data: Data?
    @NSManaged public var isRegistered: Bool
    @NSManaged public var userName: String?

}

extension KeyWallet : Identifiable {

}
