//
//  AppStatus+CoreDataProperties.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/19/23.
//
//

import Foundation
import CoreData


extension AppStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppStatus> {
        return NSFetchRequest<AppStatus>(entityName: "AppStatus")
    }

    @NSManaged public var hasBeenOpenedBefore: Bool

}

extension AppStatus : Identifiable {

}
