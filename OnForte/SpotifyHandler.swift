//
//  SpotifyHandler.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import Alamofire

class SpotifyHandler: SearchHandler {
    let tracksKey = "tracks"
    let itemsKey = "items"
    let artistsKey = "artists"
    let albumKey = "album"
    let imagesKey = "images"
    let urlKey = "url"
    let spotifyIdKey = "id"

    func parseResults(value: AnyObject) {
        results = []
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

                        results.append(SearchSong(
                            title: item[nameKey] as? String,
                            annotation: annotation,
                            musicPlatform: .Spotify,
                            artworkURL: artworkURL,
                            trackId: item[spotifyIdKey] as! String))
                    }
                }
            }
        }
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
                    self.parseResults(value)
                    completionHandler(success: true)
                }
            }
        } else {
            results = []
            completionHandler(success: false)
        }
    }
}