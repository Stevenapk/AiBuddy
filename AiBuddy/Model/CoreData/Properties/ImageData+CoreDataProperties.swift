//
//  ImageData+CoreDataProperties.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/15/23.
//
//

import Foundation
import CoreData


extension ImageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageData> {
        return NSFetchRequest<ImageData>(entityName: "ImageData")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var character: Character?

}

extension ImageData : Identifiable {

}
