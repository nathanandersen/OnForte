//
//  Song.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//
import Foundation
import UIKit

enum Service {
    case Spotify
    case Soundcloud
    case iTunes

    init(platform: String) {
        if platform.lowercaseString == "soundcloud" {
            self = .Soundcloud
        } else if platform.lowercaseString == "itunes" {
            self = .iTunes
        } else if platform.lowercaseString == "spotify" {
            self = .Spotify
        } else {
            fatalError()
        }
    }

    init(intValue: Int) {
        switch(intValue) {
        case 0:
            self = .Spotify
        case 1:
            self = .Soundcloud
        case 2:
            self = .iTunes
        case _:
            fatalError()
        }
    }

    func tintColor() -> UIColor {
        if self == .Spotify {
            return Style.spotifyGreen
        } else if self == .Soundcloud {
            return Style.soundcloudOrange
        } else if self == .iTunes {
            return Style.itunesRed
        } else {
            fatalError()
        }
    }

    func intValue() -> Int {
        if self == .Spotify {
            return 0
        } else if self == .Soundcloud {
            return 1
        } else if self == .iTunes {
            return 2
        } else {
            fatalError()
        }
    }

    func getImage() -> UIImage {
        if self == .Spotify {
            return UIImage(named: "spotify")!
        } else if self == .Soundcloud {
            return UIImage(named: "soundcloud")!
        } else if self == .iTunes {
            return UIImage(named: "itunes")!
        } else {
            fatalError()
        }
    }

    func asLowerCaseString() -> String {
        if self == .Spotify {
            return "spotify"
        } else if self == .Soundcloud {
            return "soundcloud"
        } else if self == .iTunes {
            return "itunes"
        } else {
            fatalError()
        }
    }
}

/**
 A basic class to encapsulate a song
 */

class InternalSong: Hashable {
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

    init(songDoc: MeteorSong) {
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

/*    func getSongDocFields() -> [String] {
        let fields = [
            PlaylistHandler.playlistId,
            (self.title != nil) ? self.title! : "",
            (self.description != nil) ? self.description! : "",
            String(self.service!),
            (self.trackId != nil) ? self.trackId! : "",
            (self.artworkURL != nil) ? self.artworkURL!.URLString : ""
        ]
        return fields
    }*/


}

func ==(lhs: InternalSong, rhs: InternalSong) -> Bool {
    return lhs.hashValue == rhs.hashValue
}