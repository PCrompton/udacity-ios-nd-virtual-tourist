//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/31/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var data: NSData?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var index: Int16
    @NSManaged public var pin: Pin?

}
