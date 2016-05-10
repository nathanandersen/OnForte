//
//  SearchHandler.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SwiftDDP

/**
 SearchHandler is a protocol for working with music search tables
 */
protocol SearchHandler: UITableViewDelegate, UITableViewDataSource {

    /**
     search results to display in the table
    */
    var results: [Song] { get set }

    /**
     Search the API for the music
    */
    func search(query: String)

    /**
     UITableView protocol methods
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
}

// Implementation of common methods amongst all SearchHandlers
extension SearchHandler {
    /**
     Add the song to the Meteor database and suggested songs
     */
    func addSongToPlaylist(song: Song) {
        Meteor.call("addSongWithAlbumArtURL",params: song.getSongDocFields(),callback: {(result: AnyObject?, error: DDPError?) in
            activityIndicator.showComplete("")
            NSNotificationCenter.defaultCenter().postNotificationName("completeSearch", object: nil)
        })
        addSongToSuggestions(song)
    }

    /**
     Add the song to the user-stored favorites
     */
    func addSongToSuggestions(song: Song) {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        SuggestedSong.createInManagedObjectContext(managedObjectContext, song: song)
    }

    /**
     Clear the search
    */
    func clearSearch() {
        results = [Song]()
    }
}
