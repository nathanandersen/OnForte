//
//  Song.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//
import Foundation
import UIKit

/**
 A basic class to encapsulate a song
 */
class Song: Hashable {
    var title: String?
    var description: String?
    var artworkURL: NSURL?
    var service: Service?
    var trackId: String?
    var id: String?

    var hashValue: Int {
        get {
            return "\(self.title)+\(self.description)+\(self.artworkURL)+\(self.service?.asLowerCaseString())+\(self.trackId))".hashValue
        }
    }

    init(title: String?, description: String?, service: Service?, trackId: String?, artworkURL: NSURL?) {
        self.title = title
        self.description = description
        self.service = service
        self.trackId = trackId
        self.artworkURL = artworkURL
    }

    init(songDoc: SongDocument) {
        self.title = songDoc.title
        self.trackId = String(songDoc.trackId)
        self.description = songDoc.annotation
        self.artworkURL = (songDoc.artworkURL != nil) ? NSURL(string: songDoc.artworkURL!) : nil
        self.service = Service(platform: songDoc.platform)
        self.id = songDoc._id
    }

    init(suggestedSong: SuggestedSong) {
        self.title = suggestedSong.title
        self.trackId = suggestedSong.trackId
        self.description = suggestedSong.annotation
        self.artworkURL = NSURL(string: suggestedSong.artworkURL!)
        self.service = Service(platform: suggestedSong.service!)
    }

    init(favoritedSong: FavoritedSong) {
        self.title = favoritedSong.title
        self.trackId = favoritedSong.trackId
        self.description = favoritedSong.annotation
        self.artworkURL = NSURL(string: favoritedSong.artworkURL!)
        self.service = Service(platform: favoritedSong.service!)
    }

    func getSongDocFields() -> [String] {
        let fields = [
            playlistId!,
            (self.title != nil) ? self.title! : "",
            (self.description != nil) ? self.description! : "",
            String(self.service!),
            (self.trackId != nil) ? self.trackId! : "",
            (self.artworkURL != nil) ? self.artworkURL!.URLString : ""
        ]
        return fields
    }


}

func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.hashValue == rhs.hashValue
}