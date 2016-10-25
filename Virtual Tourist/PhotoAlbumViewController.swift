//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/17/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: CoreDataViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var pin: Pin?
    var photoURLs: [URL]?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotationToMapView(completion: nil)
        
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "data", ascending: true)]
        if let pin = self.pin {
            let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
            fetchRequst.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        executeSearch()
    }
    
    func setPhotoUrls(completion: @escaping () -> Void) {
        if let pin = pin, let photos = pin.photos, photos.count == 0 {
            let client = FlickrClient.sharedInstance()
            client.search(by: pin.latitude, by: pin.longitude) { (photosArray) in
                performUpdatesOnMain {
                    self.photoURLs = [URL]()
                    for photo in photosArray {
                        self.photoURLs?.append(photo.url)
                    }
                    completion()
                }
            }
        }
    }
    
    func addAnnotationToMapView(completion: (() -> Void)?) {
        
        if let annotation = pin?.annotation {
            mapView.addAnnotation(annotation)
            mapView.centerCoordinate = annotation.coordinate
        }
        completion?()
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
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let pin = pin, let photos = pin.photos, photos.count > 0 {
            return photos.count
        } else {
            return 10
        }
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionViewCell
        if let pin = pin, let photos = pin.photos, photos.count > 0 {
            let photo = fetchedResultsController?.object(at: indexPath) as! Photo
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = photo.image
        } else {
            setPhotoUrls {
                let flickrClient = FlickrClient.sharedInstance()
                guard let photoURLs = self.photoURLs, photoURLs.count >= 10 else {
                    fatalError("No photosURLs found!")
                }
                let url = photoURLs[indexPath.row]
                flickrClient.getPhoto(from: url) { (data, error) in
                    guard error == nil else {
                        fatalError("Error found: \(error)")
                    }
                    guard let data = data else {
                        fatalError("No Data returned!")
                    }
                    guard let image = UIImage(data: data) else {
                        fatalError("Unable to Convert data to UIImage: \(data)")
                    }
                    cell.activityIndicator.stopAnimating()
                    cell.imageView.image = image
                    self.savePhoto(data: data, url: url)
                }
            }
        }
        return cell
    }
    
    func savePhoto(data: Data, url: URL) {
        print("Will Instantiate Photo")
        let photo = Photo(with: data as NSData, insertInto: stack.context)
        photo.pin = pin
        photo.url = url.absoluteString
        stack.safeSaveContext()
    }
    
    // MARK: UICollectionViewDelegate
    
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
}
