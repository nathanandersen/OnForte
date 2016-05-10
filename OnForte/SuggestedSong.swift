//
//  SuggestedSong.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import CoreData


class SuggestedSong: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    class func createInManagedObjectContext(moc: NSManagedObjectContext, song: Song) -> SuggestedSong {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("SuggestedSong", inManagedObjectContext: moc) as! SuggestedSong
        newItem.title = song.title
        newItem.annotation = song.description
        newItem.artworkURL = String(song.artworkURL)
        newItem.trackId = song.trackId
        return newItem
    }

}
