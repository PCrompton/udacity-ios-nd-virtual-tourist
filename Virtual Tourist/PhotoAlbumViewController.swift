//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var annotation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let annotation = annotation {
            mapView.addAnnotation(annotation)
            mapView.centerCoordinate = annotation.coordinate
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func newCollectionButton(_ sender: AnyObject) {
    }
}
