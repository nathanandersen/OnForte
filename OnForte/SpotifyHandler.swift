//
//  SpotifySearchController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftDDP

class SpotifyHandler: NSObject, SearchHandler {
    var results: [Song] = []

    func clearSearch() {
        results = [Song]()
    }

    func search(query: String) {
        if (query != ""){
            print("Searching spotify for:" + query)
            let parameters = [
                "q": query,
                "type": "track,artist,album"
            ]

            Alamofire.request(.GET, "https://api.spotify.com/v1/search", parameters: parameters).responseJSON { response in

                guard response.result.error == nil else {
                    print("Error occurred during spotify request")
                    print(response.result.error!)
                    return
                }

                if let value: AnyObject = response.result.value {
                    print("spotify success")
                    self.results = self.parseSpotifyTracks(JSON(value))
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadSearchResults", object: nil)
                }
            }
        } else {
            results = []
        }
    }

    func parseSpotifyTracks(json: JSON) -> [Song] {
        print("Parsing spotify results")

        var songs: [Song] = []
        let tracks = json["tracks"]["items"]
        for (_,subJson):(String, JSON) in tracks {
            let song = Song(
                title: subJson["name"].string,
                description: subJson["artists"][0]["name"].string,
                service: Service.Spotify,
                trackId: subJson["id"].string!,
                artworkURL: NSURL(string: subJson["album"]["images"][1]["url"].string!))

            songs += [song]
        }

        return songs
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultsTableViewCell")! as! SearchResultsTableViewCell

        let cell = tableView.dequeueReusableCellWithIdentifier("SongViewCell") as! SongViewCell
        cell.loadItem(results[indexPath.row])

//        artworkHandler.lookupForCell(results[indexPath.row].artworkURL!, imageView: cell.albumImage, cell: cell)


        return cell;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        activityIndicator.showActivity("Adding Song")
        addSongToPlaylist(results[indexPath.row])
    }

    func addSongToPlaylist(song: Song) {
        Meteor.call("addSongWithAlbumArtURL",params: song.getSongDocFields(),callback: {(result: AnyObject?, error:DDPError?) in
            activityIndicator.showComplete("Added")
            NSNotificationCenter.defaultCenter().postNotificationName("completeSearch", object: nil)
        })
    }
    
}