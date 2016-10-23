//
//  SuperClient.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

class SuperClient: NSObject {
    
    // MARK: HTTPMethods
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: Properties
    var session = URLSession.shared
    
    func getURL(for urlComponents: URLComponents, with path: String?, with parameters: [String: Any]?) -> URL {
        
        var components = urlComponents
        if let path = path {
            components.path += path
        }
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    func createAndRunTask(for request: URLRequest, taskCompletion: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            performUpdatesOnMain {
                guard (error == nil) else {
                    taskCompletion(nil, error)
                    return
                }
                
                guard let data = data else {
                    taskCompletion(nil, error)
                    return
                }
                
                SuperClient.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: taskCompletion)
            }
        }

        task.resume()
    }
    
    func createRequest(for url: URL, as type: HTTPMethod?, with headers: [String: String]?, with body: String?) -> URLRequest {
        var request = URLRequest(url: url)
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if let type = type {
            request.httpMethod = type.rawValue
        }
        if let body = body {
            request.httpBody = body.data(using: String.Encoding.utf8)
        }
        return request
    }
    
    class func serializeDataToJson(data: Data) throws -> [String: Any]? {
        let parsedResult: [String: Any]?
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        return parsedResult
    }
    
    class func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: [String: Any]?, _ error: NSError?) -> Void) {
        let parsedResult: [String: Any]?
        do {
            parsedResult = try serializeDataToJson(data: data)
            completionHandlerForConvertData(parsedResult, nil)
        } catch {
            let newData = data.subdata(in: Range(5...data.count))
            do {
                parsedResult = try serializeDataToJson(data: newData)
                completionHandlerForConvertData(parsedResult, nil)
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
            }
        }
        
    }

}
