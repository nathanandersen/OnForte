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

    /*
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
        SearchHandler.addSongToPlaylist(results[indexPath.row])
    }*/

    /**
     Add the song to the database and the user-stored favorites
    */
    internal static func addSongToPlaylist(song: Song) {
        addSongToDatabase(song, completionHandler: {
            activityIndicator.showComplete("")
            NSNotificationCenter.defaultCenter().postNotificationName("completeSearch", object: nil)
        })
        SongHandler.insertIntoSuggestions(song)
    }

    /**
     Add the song to the Meteor database
     */
    internal static func addSongToDatabase(song: Song, completionHandler: () -> Void) {
        Meteor.call("addSongWithAlbumArtURL",params: song.getSongDocFields(),callback: {(result: AnyObject?, error: DDPError?) in
            completionHandler()
        })
    }

    /*
    /**
     Add the song to the user-stored favorites
     */
    internal static func addSongToSuggestions(song: Song) {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedObjectContext = appDelegate.managedObjectContext
        SongHandler.insertIntoSuggestions(song)

//        SuggestedSong.createInManagedObjectContext(managedObjectContext, song: song)
//        appDelegate.saveContext()
    }*/

    /**
     Clear the search
     */
    func clearSearch() {
        results = [Song]()
    }
}