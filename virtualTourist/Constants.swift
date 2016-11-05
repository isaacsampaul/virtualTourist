//
//  Constants.swift
//  virtualTourist
//
//  Created by Isaac sam paul on 10/29/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import MapKit
struct constants
{
    static var latitude: Double!
    static var longitude: Double!
    static var coordinate: CLLocationCoordinate2D!
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLonRange = (-180.0, 180.0)
    static var imagesToDisplay: [Photo] = []
    static var indexOfData: Int!
    static var finishedLoading = false
    static var loadedData: Pin?
    static var imageData: [NSData] = []
    static var imageID: [String] = []
    static var iserror = false
    static var errorTitle = ""
    static var errorMessage = ""
    static var progress: Float = 0
}

