//
//  CoreDataViewController.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/23/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class CoreDataViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    init(fetchedResultsController: NSFetchedResultsController<NSManagedObject>) {
        self.fetchedResultsController = fetchedResultsController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}
