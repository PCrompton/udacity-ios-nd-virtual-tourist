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
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var pin: Pin?
    var photos = [Photo]()
    let maxPhotos: Int = 24
   
    let itemsPerRowInPortrait = 3
    let itemsPerRowInLandscape = 6
    let spaceBetweenItems: CGFloat = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.allowsMultipleSelection = true
        configureFlowLayout(viewWidth: self.view.frame.width, viewHeight: self.view.frame.height)
        
        addAnnotationToMapView(completion: nil)
        
        fetchStoredPhotos() {
            performUpdatesOnMain {
                self.photoCollectionView.reloadData()
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
    
    func setFetchedResultsController() {
        photos.removeAll()
        let fetchRequst = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        fetchRequst.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        if let pin = self.pin {
            let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
            fetchRequst.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequst, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        executeSearch()

    }
    
    func fetchStoredPhotos(completion: (() -> Void)?) {
        setFetchedResultsController()
        if let numSavedPhotos = fetchedResultsController?.fetchedObjects?.count {
            if numSavedPhotos == 0 {
                setPhotos() {
                    performUpdatesOnMain {
                        print("set photos")
                        self.stack.safeSaveContext()
                        completion?()
                    }
                }
            } else {
                for item in fetchedResultsController!.fetchedObjects! {
                    if let photo = item as? Photo {
                        photos.append(photo)
                    }
                }
                completion?()
            }
        }
    }
    
    func setPhotos(completion: (() -> Void)?) {
        if let pin = pin {
            let client = FlickrClient.sharedInstance()
            client.search(by: pin.latitude, by: pin.longitude) { (photosArray) in
                performUpdatesOnMain {
                    if let totalPhotos = Int16(exactly: photosArray.count) {
                        self.pin?.totalPhotos = totalPhotos
                    } else {
                        self.pin?.totalPhotos = 0
                    }
                    let startIndex: Int
                        
                    if self.pin!.set == 0 {
                        startIndex = photosArray.startIndex
                    } else {
                        startIndex = (self.maxPhotos * Int(self.pin!.set)) % Int(self.pin!.totalPhotos)
                    }
                    self.creatPhotos(from: photosArray[startIndex...photosArray.endIndex-1])
                    if self.photos.count < self.maxPhotos {
                        self.creatPhotos(from: photosArray[photosArray.startIndex...photosArray.endIndex-1])
                    }
                    completion?()
                }
            }
        }
    }
    
    func creatPhotos(from metaArray: ArraySlice<FlickrClient.PhotoMeta>) {
        for photoMeta in metaArray {
            if self.photos.count >= self.maxPhotos {
                break
            }
            let photo = self.createPhoto(from: photoMeta)
            self.photos.append(photo)
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
        if photoCollectionView.indexPathsForSelectedItems?.count != 0 {
            var photosToDelete = [Photo]()
            for indexPath in photoCollectionView.indexPathsForSelectedItems! {
                photosToDelete.append(photos[indexPath.item])
            }
    
            for photo in photosToDelete {
                stack.context.delete(photo)
                photos.remove(at: photos.index(of: photo)!)
            }
            stack.safeSaveContext()
            photoCollectionView.reloadData()
            updateButton()
        

        } else {
            stack.delete(objects: photos)
            stack.safeSaveContext()
            photos.removeAll()
            pin?.set += 1
            setPhotos {
                performUpdatesOnMain {
                    self.stack.safeSaveContext()
                    self.photoCollectionView.reloadData()
                    
                    self.updateButton()
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        photos[indexPath.item].index = Int16(exactly: indexPath.item)!
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.alpha = 1.0
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
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        print(cell.isSelected)
        if cell.isSelected {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        print(cell.isSelected)
        cell.imageView.alpha = 0.5
        updateButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        if cell.isSelected {
            return true
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        print(cell.isSelected)
        cell.imageView.alpha = 1.0
        updateButton()
    }
    
    func updateButton() {
       if photoCollectionView.indexPathsForSelectedItems?.count != 0 {
            newCollectionButton.title = "Delete Selected Photos"
       } else {
            newCollectionButton.title = "New Collection"
        }
    }
}
