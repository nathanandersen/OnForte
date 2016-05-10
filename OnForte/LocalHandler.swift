//
//  iTunesSearchController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import Alamofire
import SwiftDDP
import SwiftyJSON

class LocalHandler: NSObject, SearchHandler {
    
    var results: [Song] = []

    func clearSearch() {
        results = [Song]()
    }

    func search(query: String) {
        if (query != ""){
            results = allLocalITunes.filter({ (song) -> Bool in
                let title: NSString = song.title!
                let range = title.rangeOfString(query, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            })
        }
        else {
            results = []
        }
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

    func addSongToPlaylist(song: Song) {
        Meteor.call("addSongWithAlbumArtURL",params: song.getSongDocFields(),callback: {(result: AnyObject?, error: DDPError?) in
            activityIndicator.showComplete("")
            NSNotificationCenter.defaultCenter().postNotificationName("completeSearch", object: nil)
        })
    }

}