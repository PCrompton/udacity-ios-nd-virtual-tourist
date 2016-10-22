//
//  ClientConstants.swift
//  On The Map
//
//  Created by Paul Crompton on 9/26/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import Foundation

extension SuperClient {
    
    // MARK: Client Constants
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    struct HTTPHeaderKeys {
        static let accept = "Accept"
        static let contentType = "Content-Type"
    }
    
    struct HTTPHeaderValues {
        static let json = "application/json"
    }
}
