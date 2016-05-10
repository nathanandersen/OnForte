//
//  SuggestedSong+CoreDataProperties.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SuggestedSong {

    @NSManaged var title: String?
    @NSManaged var annotation: String?
    @NSManaged var artworkURL: String?
    @NSManaged var trackId: String?
    @NSManaged var service: NSNumber?

}
