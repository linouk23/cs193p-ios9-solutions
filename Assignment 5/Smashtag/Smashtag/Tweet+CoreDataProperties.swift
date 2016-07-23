//
//  Tweet+CoreDataProperties.swift
//  Smashtag
//
//  Created by Kanstantsin Linou on 7/23/16.
//  Copyright © 2016 self.edu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tweet {

    @NSManaged var text: String?
    @NSManaged var unique: String?
    @NSManaged var posted: NSDate?
    @NSManaged var queries: NSSet?
    @NSManaged var mentions: NSSet?

}
