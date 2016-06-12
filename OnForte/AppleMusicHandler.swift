//
//  AppleMusicHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 6/11/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import Alamofire


class AppleMusicHandler: SearchHandler {

    let appleMusicApiLink = "https://itunes.apple.com/search?"
    let mediaKey = "media"
    let mediaValue = "music"
    let entityKey = "entity"
    let entityValue = "song"
    let limitKey = "limit"
    let limitCount = 20
    let termKey = "term"
    let resultsKey = "results"
    let artistKey = "artistName"
    let imageKey = "artworkUrl100"
    let nameKey = "trackName"
    let trackIdKey = "trackId"

    override func search(query: String, completionHandler: (success: Bool) -> Void) {
        results = []
        if query != "" {
            print(query)
            let parameters = [
                mediaKey:mediaValue,
                entityKey:entityValue,
                limitKey:String(limitCount),
                termKey:query
            ]

            Alamofire.request(.GET, appleMusicApiLink, parameters: parameters).responseJSON { response in
                guard response.result.error == nil else {
                    print("Error occurred during spotify request")
                    print(response.result.error!)
                    completionHandler(success: false)
                    return
                }
                if let value: AnyObject = response.result.value as? [String:AnyObject] {
                    if let tracks = value[self.resultsKey] as? [[String:AnyObject]] {
                        for track in tracks {
                            var url: NSURL? = nil
                            if let imageUrl = track[self.imageKey] as? String {
                                url = NSURL(string: imageUrl)
                            }
                            self.results.append(SearchSong(
                                title: track[self.nameKey] as? String,
                                annotation: track[self.artistKey] as? String,
                                musicPlatform: .AppleMusic,
                                artworkURL: url,
                                trackId: String(track[self.trackIdKey] as! Int)))
                        }
                    }
                    completionHandler(success: true)
                }

            }

        }
    }
}