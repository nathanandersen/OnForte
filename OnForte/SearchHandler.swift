//
//  SearchHandler.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation

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

    /**
     Add the song to the Meteor database
    */
    func addSongToPlaylist(song: Song)

    /**
     Clear the search
    */
    func clearSearch()
}
