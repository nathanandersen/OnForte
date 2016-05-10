//
//  SoundcloudSearchController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import SwiftDDP
import Soundcloud

/**
 SoundCloudHandler is a SearchHandler to search SoundCloud music.
 */
class SoundCloudHandler: SearchHandler {

    override func search(query: String) {
        if (query != ""){
            print("Searching soundcloud for:" + query)
            let apiQuery: [SearchQueryOptions] = [
                .QueryString(query)
            ]
            Track.search(apiQuery) { (paginatedTracks) -> Void in
                switch paginatedTracks.response {
                case .Success(let tracks):
                    self.results = self.parseSoundcloudTracks(tracks)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadSearchResults", object: nil)
                case .Failure(let error):
                    print(error)
                }
            }
        } else {
            results = []
        }
    }

    func parseSoundcloudTracks(tracks: [Track]) -> [Song] {
        var songs: [Song] = []
        for track in tracks {
            let song = Song(
                title: track.title,
                description: track.description,
                service: Service.Soundcloud,
                trackId: String(track.identifier),
                artworkURL: track.artworkImageURL.largeURL)

            songs += [song]
        }
        return songs
    }
}