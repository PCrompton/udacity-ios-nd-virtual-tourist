//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/23/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData

extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var page: Int16
    @NSManaged public var pages: Int16
    @NSManaged public var perPage: Int16
    @NSManaged public var total: Int16
    @NSManaged public var photo: NSOrderedSet?

}

// MARK: Generated accessors for photo
extension Pin {

    @objc(insertObject:inPhotoAtIndex:)
    @NSManaged public func insertIntoPhoto(_ value: Photo, at idx: Int)

    @objc(removeObjectFromPhotoAtIndex:)
    @NSManaged public func removeFromPhoto(at idx: Int)

    @objc(insertPhoto:atIndexes:)
    @NSManaged public func insertIntoPhoto(_ values: [Photo], at indexes: NSIndexSet)

    @objc(removePhotoAtIndexes:)
    @NSManaged public func removeFromPhoto(at indexes: NSIndexSet)

    @objc(replaceObjectInPhotoAtIndex:withObject:)
    @NSManaged public func replacePhoto(at idx: Int, with value: Photo)

    @objc(replacePhotoAtIndexes:withPhoto:)
    @NSManaged public func replacePhoto(at indexes: NSIndexSet, with values: [Photo])

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSOrderedSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSOrderedSet)

}
