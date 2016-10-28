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
            if let data = data {
               return UIImage(data: data as Data)
            } else {
                return nil
            }
        }
    }
    
    convenience init(with url: String?, pin: Pin?, title: String?, insertInto context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.url = url
            self.pin = pin
            self.title = title
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
