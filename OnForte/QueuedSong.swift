//
//  QueuedSong.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/30/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import CoreData


class QueuedSong: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

     class func createInManagedObjectContext(moc: NSManagedObjectContext, song: Song) -> QueuedSong {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("QueuedSong", inManagedObjectContext: moc) as! QueuedSong
        newItem.title = song.title
        newItem.annotation = song.annotation
        newItem.id = song._id
        newItem.playlistId = song.playlistId
        newItem.createDate = song.createDate
        newItem.musicPlatform = song.musicPlatform.asLowercaseString()
        newItem.artworkURL = String(song.artworkURL!)
        newItem.trackId = song.trackId
        newItem.score = song.score
        newItem.userId = song.userId
        newItem.activeStatus = song.activeStatus.rawValue
        return newItem
     }
}
