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
    
    override func viewDidLoad() {
        title = "Virtual Tourist"
        
        // Get the stack
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "page", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        executeSearch()
        for object in fetchedResultsController!.fetchedObjects! {
            if let pin = object as? Pin {
                mapView.addAnnotation(pin.annotation)
            }
        }
    }
    
    @IBAction func editButton(_ sender: AnyObject) {
    }
    @IBAction func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            let touchPoint = recognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let pin = Pin(with: coordinate, insertInto: stack.context)
            mapView.addAnnotation(pin.annotation)
            stack.safeSaveContext()
        }
    }
    
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
        let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        if let annotation = view.annotation as? PointAnnotation {
            photoAlbumVC.pin = annotation.pin
            self.show(photoAlbumVC, sender: self)
        }
    }
}
