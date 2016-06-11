//
//  SoundcloudHandler.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import SwiftDDP
import Soundcloud

/**
 SoundcloudHandler is a SearchHandler to search SoundCloud music.
 */
class SoundcloudHandler: SearchHandler {

    override func search(query: String, completionHandler: (success: Bool) -> Void) {
        results = []
        if (query != ""){
            let apiQuery: [SearchQueryOptions] = [
                .QueryString(query)
            ]
            Track.search(apiQuery) { (paginatedTracks) -> Void in
                switch paginatedTracks.response {
                case .Success(let tracks):
                    for track in tracks {
                        self.results.append(
                            SearchSong(
                                title: track.title,
                                annotation: track.description,
                                musicPlatform: MusicPlatform.Soundcloud,
                                artworkURL: track.artworkImageURL.largeURL,
                                trackId: String(track.identifier)))
                    }
                    completionHandler(success: true)
                case .Failure(let error):
                    print(error)
                    completionHandler(success: false)
                }
            }
        } else {
            completionHandler(success: false)
        }
    }
}