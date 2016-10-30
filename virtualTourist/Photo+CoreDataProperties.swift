//
//  Photo+CoreDataProperties.swift
//  virtualTourist
//
//  Created by Isaac sam paul on 10/30/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var pin: Pin?

}
