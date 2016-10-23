//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var annotation: MKAnnotation?
    var photos: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotationToMapView { 
            performUpdatesOnMain {
                self.getPhotos()
            }
        }
    }
    
    func addAnnotationToMapView(completion: (() -> Void)?) {
        if let annotation = annotation {
            mapView.addAnnotation(annotation)
            mapView.centerCoordinate = annotation.coordinate
        }
        completion?()
    }
    
    func getPhotos() {
        if let annotation = annotation {
            FlickrClient.sharedInstance().search(by: annotation.coordinate.latitude, by: annotation.coordinate.longitude) { (results) in
                performUpdatesOnMain {
                    self.photos = results
                }
            }
        } else {
            photos = nil
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = PhotoCollectionViewCell()
        
        return cell
    }
}
