//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelLocationsMapViewController: CoreDataViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editIndicator: UILabel!
    
    override func viewDidLoad() {
        title = "Virtual Tourist"
        
        // Get the stack
        fetchStoredPins { (fetchedPins) in
            performUpdatesOnMain {
                for pin in fetchedPins {
                    self.mapView.addAnnotation(pin.annotation)
                }
            }
        }
    }
    
    func fetchStoredPins(completion: ((_ fetchedPins: [Pin]) -> Void)?) {
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        executeSearch()
        completion?(fetchedResultsController?.fetchedObjects as! [Pin])
    }
    
    @IBAction func editButton(_ sender: AnyObject) {
        editIndicator.isHidden = !editIndicator.isHidden
    }
    
    @IBAction func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            let touchPoint = recognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let pin = Pin(with: coordinate, insertInto: fetchedResultsController!.managedObjectContext)
            mapView.addAnnotation(pin.annotation)
            print("save pin")
            stack.save()
        }
    }
    
    // Mark: MKMapViewDelegate Functions
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? PointAnnotation {
            if editIndicator.isHidden {
                let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
                photoAlbumVC.pin = annotation.pin
                self.show(photoAlbumVC, sender: self)
                mapView.deselectAnnotation(annotation, animated: false)
            } else {
                mapView.removeAnnotation(annotation)
                stack.save()
            }
        }
    }
}
