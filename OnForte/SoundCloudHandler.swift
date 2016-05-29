//
//  SoundcloudSearchController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import SwiftDDP
import Soundcloud

/**
 SoundCloudHandler is a SearchHandler to search SoundCloud music.
 */
class SoundCloudHandler: SearchHandler {

    override func search(query: String, completionHandler: (success: Bool) -> Void) {
        if (query != ""){
            let apiQuery: [SearchQueryOptions] = [
                .QueryString(query)
            ]
            Track.search(apiQuery) { (paginatedTracks) -> Void in
                switch paginatedTracks.response {
                case .Success(let tracks):
                    self.results = self.parseSoundcloudTracks(tracks)
                    completionHandler(success: true)
                case .Failure(let error):
                    print(error)
                    completionHandler(success: false)
                }
            }
        } else {
            results = []
            completionHandler(success: false)
        }
    }

    func parseSoundcloudTracks(tracks: [Track]) -> [InternalSong] {
        var songs: [InternalSong] = []
        for track in tracks {
            let song = InternalSong(
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