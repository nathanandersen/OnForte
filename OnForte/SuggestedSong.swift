//
//  SuggestedSong.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/10/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import CoreData


class SuggestedSong: NSManagedObject {

    class func createInManagedObjectContext(moc: NSManagedObjectContext, song: SearchSong) -> SuggestedSong {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("SuggestedSong", inManagedObjectContext: moc) as! SuggestedSong
        newItem.title = song.title
        newItem.annotation = song.annotation
        newItem.artworkURL = String(song.artworkURL!)
        newItem.trackId = song.trackId
        newItem.service = song.musicPlatform.asLowercaseString()
//        newItem.service = song.service!.asLowerCaseString()
        return newItem
    }

}
