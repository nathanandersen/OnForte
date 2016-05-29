//
//  SearchHandler.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import SwiftDDP

/**
 SearchHandler is a abstract class for working with music search tables. Has to be implemented and have search overriden.
 */
class SearchHandler: NSObject/*, UITableViewDelegate, UITableViewDataSource*/ {
    var results: [Song] = [Song]()

    /**
     Search the service for the query. Must be overriden.
     - parameters:
        - query: the search parameter
        - callback: a function to call on completion, (Bool) success
    */
    func search(query: String, completionHandler: (success: Bool) -> Void) {
        fatalError("cannot search on an abstract SearchHandler")
    }

    /**
     Add the song to the database and the user-stored favorites
    */
    internal static func addSongToPlaylist(song: Song) {
        NSNotificationCenter.defaultCenter().postNotificationName(closeSearchKey, object: nil)
/*        MeteorHandler.addSongToDatabase(song, completionHandler: {
            NSNotificationCenter.defaultCenter().postNotificationName(closeSearchKey, object: nil)
        })*/
        MeteorHandler.addSongToDatabase(song, completionHandler: {
            NSNotificationCenter.defaultCenter().postNotificationName(reloadTableKey, object: nil)
            // hide the activity indicator -> or some sort of visual confirmation
        })
        SongHandler.insertIntoSuggestions(song)
    }

    /**
     Clear the search
     */
    func clearSearch() {
        results = [Song]()
    }
}