//
//  FavoritedSong.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import CoreData


class FavoritedSong: NSManagedObject {

    class func createInManagedObjectContext(moc: NSManagedObjectContext, song: Song) -> FavoritedSong {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("FavoritedSong", inManagedObjectContext: moc) as! FavoritedSong
        newItem.title = song.title
        newItem.annotation = song.description
        newItem.artworkURL = String(song.artworkURL)
        newItem.trackId = song.trackId
        return newItem
    }

}
