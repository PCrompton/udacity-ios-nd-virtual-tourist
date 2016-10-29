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

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var pin: Pin?
    var photos = [Photo]()
    let maxPhotos: Int = 24
   
    let itemsPerRowInPortrait = 3
    let itemsPerRowInLandscape = 6
    let spaceBetweenItems: CGFloat = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFlowLayout(viewWidth: self.view.frame.width, viewHeight: self.view.frame.height)
        
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
        if let numSavedPhotos = fetchedResultsController?.fetchedObjects?.count {
            
            if numSavedPhotos != maxPhotos {
                setPhotos() {
                    performUpdatesOnMain {
                        print("set photos")
                        self.stack.safeSaveContext()
                        self.photoCollectionView.reloadData()
                    }
                }
            } else {
                for item in fetchedResultsController!.fetchedObjects! {
                    if let photo = item as? Photo {
                        photos.append(photo)
                    }
                }
                photoCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let newWidth = self.view.frame.height
        let newHeight = self.view.frame.width
        configureFlowLayout(viewWidth: newWidth, viewHeight: newHeight)
        
    }
    
    func configureFlowLayout(viewWidth width: CGFloat, viewHeight height: CGFloat) {
        let numPerRow: Int
        if width < height {
            numPerRow = itemsPerRowInPortrait
        } else {
            numPerRow = itemsPerRowInLandscape
        }
        let dimension = (width - (CGFloat(numPerRow-1) * spaceBetweenItems)) / CGFloat(numPerRow)
        flowLayout.minimumInteritemSpacing = spaceBetweenItems
        flowLayout.minimumLineSpacing = spaceBetweenItems
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
    }
    
    func setPhotos(completion: (() -> Void)?) {
        if let pin = pin {
            let client = FlickrClient.sharedInstance()
            client.search(by: pin.latitude, by: pin.longitude) { (photosArray) in
                performUpdatesOnMain {
                    for photoMeta in photosArray {
                        if self.photos.count >= self.maxPhotos {
                            break
                        }
                        let photo = self.createPhoto(from: photoMeta)
                        self.photos.append(photo)
                    }
                    completion?()
                }
            }
        }
    }
    
    func createPhoto(from meta: FlickrClient.PhotoMeta) -> Photo {
        return Photo(with: meta.url.absoluteString, pin: pin!, title: meta.title, insertInto: stack.context)
    }
    
    func downloadPhoto(photo: Photo, completion: (() -> Void)?) {
        let flickrClient = FlickrClient.sharedInstance()
        guard let urlString = photo.url else {
            fatalError("No urlString found")
        }
        guard let url = URL(string: urlString) else {
            fatalError("Unable to convert \(urlString) to URL")
        }
        flickrClient.getPhoto(from: url) { (data, error) in
            
            guard error == nil else {
                fatalError("Error found while downloading photo: \(error)")
            }
            
            guard let data = data else {
                fatalError("No data found")
            }
            
            photo.data = data as NSData?
            
            guard (photo.image != nil) else {
                fatalError("no image found")
            }
            completion?()
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
        return photos.count
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionViewCell
    
        let photo = photos[indexPath.item]
        if let image = photo.image {
            print("persisted photo")
            cell.imageView.image = image
        } else {
            print("downloading photo...")
            cell.activityIndicator.startAnimating()
            downloadPhoto(photo: photo) {
                performUpdatesOnMain {
                    print("Cell for item at index path")
                    self.stack.safeSaveContext()
                    cell.activityIndicator.stopAnimating()
                    cell.imageView.image = photo.image
                }
            }
        }
        return cell
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
