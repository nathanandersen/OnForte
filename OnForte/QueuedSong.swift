//
//  QueuedSong.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/29/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import CoreData


class QueuedSong: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    class func createInManagedObjectContext(moc: NSManagedObjectContext, song: Song) -> QueuedSong {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("QueuedSong", inManagedObjectContext: moc) as! QueuedSong
        newItem.title = song.title
        newItem.annotation = song.annotation
        newItem.artworkURL = String(song.artworkURL!)
        newItem.trackId = song.trackId
        newItem.musicPlatform = song.musicPlatform.asLowercaseString()
        return newItem
    }
}
