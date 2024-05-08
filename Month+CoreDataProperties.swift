//
//  Month+CoreDataProperties.swift
//  testingEntityRelationships
//
//  Created by Jonah Whitney on 3/13/24.
//
//

import Foundation
import CoreData


extension Month {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Month> {
        return NSFetchRequest<Month>(entityName: "Month")
    }

    @NSManaged public var nameMonth: String?
    @NSManaged public var wines: NSSet?

}

// MARK: Generated accessors for wines
extension Month {

    @objc(addWinesObject:)
    @NSManaged public func addToWines(_ value: Wine)

    @objc(removeWinesObject:)
    @NSManaged public func removeFromWines(_ value: Wine)

    @objc(addWines:)
    @NSManaged public func addToWines(_ values: NSSet)

    @objc(removeWines:)
    @NSManaged public func removeFromWines(_ values: NSSet)

}

extension Month : Identifiable {

}
