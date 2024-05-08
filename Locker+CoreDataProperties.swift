//
//  Locker+CoreDataProperties.swift
//  testingEntityRelationships
//
//  Created by Jonah Whitney on 3/13/24.
//
//

import Foundation
import CoreData


extension Locker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Locker> {
        return NSFetchRequest<Locker>(entityName: "Locker")
    }

    @NSManaged public var number: String?
    @NSManaged public var owner: String?
    @NSManaged public var wines: NSSet?

}

// MARK: Generated accessors for wines
extension Locker {

    @objc(addWinesObject:)
    @NSManaged public func addToWines(_ value: Wine)

    @objc(removeWinesObject:)
    @NSManaged public func removeFromWines(_ value: Wine)

    @objc(addWines:)
    @NSManaged public func addToWines(_ values: NSSet)

    @objc(removeWines:)
    @NSManaged public func removeFromWines(_ values: NSSet)

}

extension Locker : Identifiable {

}
