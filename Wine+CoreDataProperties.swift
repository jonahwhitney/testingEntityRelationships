//
//  Wine+CoreDataProperties.swift
//  testingEntityRelationships
//
//  Created by Jonah Whitney on 3/13/24.
//
//

import Foundation
import CoreData


extension Wine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Wine> {
        return NSFetchRequest<Wine>(entityName: "Wine")
    }

    @NSManaged public var color: String?
    @NSManaged public var monthAndYearOrdered: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Float
    @NSManaged public var quantity: Int64
    @NSManaged public var type: String?
    @NSManaged public var wineDescription: String?
    @NSManaged public var locker: Locker?
    @NSManaged public var month: Month?

}

extension Wine : Identifiable {

}
