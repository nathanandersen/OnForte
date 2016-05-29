//
//  SpotifySearchController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftDDP

class SpotifyHandler: SearchHandler {

    func parseSpotifyTracks(json: JSON) -> [InternalSong] {
        var songs: [InternalSong] = []
        let tracks = json["tracks"]["items"]
        for (_,subJson):(String, JSON) in tracks {
            let song = InternalSong(
                title: subJson["name"].string,
                description: subJson["artists"][0]["name"].string,
                service: Service.Spotify,
                trackId: subJson["id"].string!,
                artworkURL: NSURL(string: subJson["album"]["images"][1]["url"].string!))

            songs += [song]
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
                    self.results = self.parseSpotifyTracks(JSON(value))
                    completionHandler(success: true)
                }
            }
        } else {
            results = []
            completionHandler(success: false)
        }
    }
}