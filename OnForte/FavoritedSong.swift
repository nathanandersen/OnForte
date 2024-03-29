//
//  FavoritedSong.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import CoreData


class FavoritedSong: NSManagedObject {

    class func createInManagedObjectContext(moc: NSManagedObjectContext, song: SearchSong) -> FavoritedSong {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("FavoritedSong", inManagedObjectContext: moc) as! FavoritedSong
        newItem.title = song.title
        newItem.annotation = song.annotation
        newItem.artworkURL = String(song.artworkURL!)
        newItem.trackId = song.trackId
        newItem.service = song.musicPlatform.asLowercaseString()
//        newItem.service = song.service!.asLowerCaseString()
        return newItem
    }

}
