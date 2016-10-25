//
//  PointAnnotation.swift
//  Virtual Tourist
//
//  Created by Paul Crompton on 10/24/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import MapKit

class PointAnnotation: MKPointAnnotation {
    let pin: Pin
    init(pin: Pin) {
        self.pin = pin
        super.init()
    }
}
