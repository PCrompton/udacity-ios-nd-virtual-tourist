//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/23/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Photo: NSManagedObject {
    
    var image: UIImage? {
        get {
            return UIImage(data: self.data as! Data)
        }
    }
    
    convenience init(with data: NSData, insertInto context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.data = data
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
