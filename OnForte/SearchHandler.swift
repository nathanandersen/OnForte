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
 SearchHandler is a abstract class for working with music search tables. Has to be implemented and have search overriden.
 */
class SearchHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    var results: [Song] = [Song]()

    /**
     Search the service for the query. Must be overriden.
    */
    func search(query: String) {
        fatalError("cannot search on an abstract SearchHandler")
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell") as! SongViewCell
        cell.loadItem(results[indexPath.row])
        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activityIndicator.showActivity("Adding Song")
        addSongToPlaylist(results[indexPath.row])
    }

    /**
     Add the song to the database and the user-stored favorites
    */
    internal func addSongToPlaylist(song: Song) {
        addSongToDatabase(song)
        addSongToSuggestions(song)
    }

    /**
     Add the song to the Meteor database
     */
    private func addSongToDatabase(song: Song) {
        Meteor.call("addSongWithAlbumArtURL",params: song.getSongDocFields(),callback: {(result: AnyObject?, error: DDPError?) in
            activityIndicator.showComplete("")
            NSNotificationCenter.defaultCenter().postNotificationName("completeSearch", object: nil)
        })
    }

    /**
     Add the song to the user-stored favorites
     */
    private func addSongToSuggestions(song: Song) {
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