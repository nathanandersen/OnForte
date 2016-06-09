//
//  QueuedSong+CoreDataProperties.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/30/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension QueuedSong {

    @NSManaged var annotation: String?
    @NSManaged var artworkURL: String?
    @NSManaged var createDate: NSDate?
    @NSManaged var id: String?
    @NSManaged var musicPlatform: String?
    @NSManaged var playlistId: String?
    @NSManaged var score: NSNumber?
    @NSManaged var title: String?
    @NSManaged var trackId: String?
    @NSManaged var userId: String?
    @NSManaged var activeStatus: NSNumber?

}
