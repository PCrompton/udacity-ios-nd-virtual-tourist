//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/23/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData

public class Photo: NSManagedObject {
    
    convenience init(data: NSData, pin: Pin, title: String?, url: String?, insertInto context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.data = data
            self.pin = pin
            self.title = title
            self.url = url
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
