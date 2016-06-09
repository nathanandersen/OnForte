//
//  SpotifyHandler.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import Alamofire
//import SwiftyJSON

let tracksKey = "tracks"
let itemsKey = "items"
let artistsKey = "artists"
let albumKey = "album"
let imagesKey = "images"
let urlKey = "url"
let spotifyIdKey = "id"

class SpotifyHandler: SearchHandler {


/*    func parseSpotifyTracks(json: JSON) -> [SearchSong] {
        var songs: [SearchSong] = []
        let tracks = json[tracksKey][itemsKey]
        for (_,subJson):(String, JSON) in tracks {
            songs.append(SearchSong(
                title: subJson[nameKey].string,
                annotation: subJson[artistsKey][0][nameKey].string,
                musicPlatform: .Spotify,
                artworkURL: NSURL(string: subJson[albumKey][imagesKey][1][urlKey].string!),
                trackId: subJson[spotifyIdKey].string!))
        }
        return songs
    }*/

    func parseResults(value: AnyObject) -> [SearchSong] {
        var songs: [SearchSong] = []
        if let dict: [String: AnyObject] = value as? [String : AnyObject] {
            if let tracks = dict[tracksKey] as? [String : AnyObject] {
                if let items = tracks[itemsKey] as? [[String:AnyObject]] {
                    for item in items {
                        var artworkURL: NSURL? = nil
                        if let albumInfo = item[albumKey] as? [String:AnyObject] {
                            if let images = albumInfo[imagesKey] as? [[String:AnyObject]] {
                                if let url = images.first?[urlKey] as? String {
                                    artworkURL = NSURL(string: url)
                                }
                            }
                        }

                        var annotation: String? = ""
                        if let artistInfo = item[artistsKey] as? [[String:AnyObject]] {
                            annotation = artistInfo.first?[nameKey] as? String
                        }

                        songs.append(SearchSong(
                            title: item[nameKey] as? String,
                            annotation: annotation,
                            musicPlatform: .Spotify,
                            artworkURL: artworkURL,
                            trackId: item[spotifyIdKey] as! String))
                    }
                }
            }
        }
        return songs
    }

    override func search(query: String, completionHandler: (success: Bool) -> Void) {
        if (query != ""){
            let parameters = [
                "q": query,
                "type": "track,artist,album"
            ]

            Alamofire.request(.GET, "https://api.spotify.com/v1/search", parameters: parameters).responseJSON { response in

                guard response.result.error == nil else {
                    print("Error occurred during spotify request")
                    print(response.result.error!)
                    completionHandler(success: false)
                    return
                }
                if let value: AnyObject = response.result.value {
                    self.results = self.parseResults(value)
//                    self.results = self.parseSpotifyTracks(JSON(value))
                    completionHandler(success: true)
                }
            }
        } else {
            results = []
            completionHandler(success: false)
        }
    }
}