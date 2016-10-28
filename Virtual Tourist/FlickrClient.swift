//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/21/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit


class FlickrClient: SuperClient {
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    func search(by latitude: Double, by longitude: Double, completion: ((_ photos: [PhotoMeta]) -> Void)?) {
        let methodParameters = [
            Constants.ParameterKeys.Method: Constants.ParameterValues.SearchMethod,
            Constants.ParameterKeys.APIKey: Constants.ParameterValues.APIKey,
            Constants.ParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
            Constants.ParameterKeys.SafeSearch: Constants.ParameterValues.UseSafeSearch,
            Constants.ParameterKeys.Extras: Constants.ParameterValues.MediumURL,
            Constants.ParameterKeys.Format: Constants.ParameterValues.ResponseFormat,
            Constants.ParameterKeys.NoJSONCallback: Constants.ParameterValues.DisableJSONCallback
        ]
        getPhotos(with: methodParameters) {(photos) in
            performUpdatesOnMain {
                completion?(photos)
            }
        }
    }
    
    func getPhotos(with methodParameters: [String: Any], completion: ((_ photos: [PhotoMeta]) -> Void)?) {
        let url = getURL(for: Constants.urlComponents, with: nil, with: methodParameters)
        print(url.absoluteString)
        let request = createRequest(for: url, as: HTTPMethod.get, with: nil, with: nil)
        
        getJson(for: request) { (result, error) in
            performUpdatesOnMain {
                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = result?[Constants.ResponseKeys.Status] as? String , stat == Constants.ResponseValues.OKStatus else {
                    fatalError("Flickr API returned an error. See error code and message in \(result)")
                }
                
                /* GUARD: Is "photos" key in our result? */
                guard let photosDictionary = result?[Constants.ResponseKeys.Photos] as? [String:Any] else {
                    fatalError("Cannot find keys '\(Constants.ResponseKeys.Photos)' in \(result)")
                }
                
                /* GUARD: Is "pages" key in the photosDictionary? */
                guard (photosDictionary[Constants.ResponseKeys.Pages] as? Int) != nil else {
                    fatalError("Cannot find key '\(Constants.ResponseKeys.Pages)' in \(photosDictionary)")
                }
                
                guard let photos = photosDictionary[Constants.ResponseKeys.Photo] as? [[String:Any]] else {
                    fatalError("Cannot find key '\(Constants.ResponseKeys.Photo)' in \(photosDictionary)")
                }
                
                var photosArray = [PhotoMeta]()
                for photo in photos {
                    
                    guard let title = photo[Constants.ResponseKeys.Title] as? String else {
                        fatalError("Cannot find key '\(Constants.ResponseKeys.Title)' in \(photo)")
                    }
                    
                    guard let urlString = photo[Constants.ResponseKeys.MediumURL] as? String else {
                        fatalError("Cannot find key '\(Constants.ResponseKeys.MediumURL)' in \(photo)")
                    }
                    
                    guard let url = URL(string: urlString) else {
                        fatalError("Cannot convert '\(urlString) to type URL")
                    }
                    
                    photosArray.append(PhotoMeta(url: url, title: title))
                }
                completion?(photosArray)
            }
        }
    }
    
    func getPhoto(from url: URL, completion: @escaping (_ imageData: Data?, _ error: Error?) -> Void) {
        let request = createRequest(for: url, as: HTTPMethod.get, with: nil, with: nil)
        createAndRunTask(for: request) { (data, error) in
            guard (error == nil) else {
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.SearchBBoxHalfWidth, Constants.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.SearchBBoxHalfHeight, Constants.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
}

extension FlickrClient {
    struct PhotoMeta {
        let url: URL
        let title: String
    }
}
