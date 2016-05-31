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

    func parseSoundcloudTracks(tracks: [Track]) -> [SearchSong] {
        var songs: [SearchSong] = []
        for track in tracks {
            songs.append(SearchSong(title: track.title, annotation: track.description, musicPlatform: MusicPlatform.Soundcloud, artworkURL: track.artworkImageURL.largeURL, trackId: String(track.identifier)))
        }
        return songs
    }
}