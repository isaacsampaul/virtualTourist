//
//  Photo+CoreDataProperties.swift
//  virtualTourist
//
//  Created by Isaac sam paul on 11/2/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var photoID: String?
    @NSManaged public var pin: Pin?

}
