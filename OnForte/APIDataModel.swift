//
//  APIDataModel.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/29/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

class Playlist: Hashable {
    var name: String
    var playlistId: String
    var _id: String
    //    var isLoggedInToSpotify: Bool
    //    var isLoggedInToSoundcloud: Bool
    //    var isLoggedInToAppleMusic: Bool
    var createDate: NSDate

    init(jsonData: AnyObject) {
        print(jsonData)
        self._id = jsonData["_id"] as! String
        self.name = jsonData["name"] as! String
        self.playlistId = jsonData["playlistId"] as! String
        self.createDate = APIHandler.convertJSONDateToNSDate(jsonData["createDate"] as! String)!
    }

    var hashValue: Int {
        get {
            return self._id.hashValue
        }
    }
}

func ==(lhs: Playlist, rhs: Playlist) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Song: Hashable {
    var title: String?
    var description: String?
    var _id: String
    var playlistId: String
    var createDate: NSDate
    var musicPlatform: MusicPlatform
    var artworkURL: NSURL?
    var trackId: String

    init(jsonData: AnyObject) {
        print(jsonData)
        self._id = jsonData["_id"] as! String
        self.title = jsonData["title"] as? String
        self.description = jsonData["description"] as? String
        self.playlistId = jsonData["playlistId"] as! String
        self.musicPlatform = MusicPlatform(str: jsonData["musicPlatform"] as! String)
        self.createDate = APIHandler.convertJSONDateToNSDate(jsonData["createDate"] as! String)!
        self.artworkURL = NSURL(string: jsonData["artworkURL"] as! String) // how are we going to catch this optional?
        self.trackId = jsonData["trackId"] as! String
    }

    var hashValue: Int {
        get {
            return self._id.hashValue
        }
    }
}

func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

enum MusicPlatform {
    case Spotify
    case Soundcloud
    case AppleMusic

    init(intValue: Int) {
        switch(intValue) {
        case 0: self = .Spotify
        case 1: self = .Soundcloud
        case 2: self = .AppleMusic
        case _: fatalError()
        }
    }

    init(str: String) {
        switch(str.lowercaseString) {
        case "applemusic": self = .AppleMusic
        case "spotify": self = .Spotify
        case "soundcloud": self = .Soundcloud
        case _: fatalError()
        }
    }

    func intValue() -> Int {
        if self == .Spotify {
            return 0
        } else if self == .Soundcloud {
            return 1
        } else if self == .AppleMusic {
            return 2
        } else {
            fatalError()
        }
    }

    func tintColor() -> UIColor {
        if self == .Spotify {
            return Style.spotifyGreen
        } else if self == .Soundcloud {
            return Style.soundcloudOrange
        } else if self == .AppleMusic {
            return Style.appleMusicRed
        } else {
            fatalError()
        }
    }

    func getImage() -> UIImage {
        if self == .Spotify {
            return UIImage(named: "spotify")!
        } else if self == .Soundcloud {
            return UIImage(named: "soundcloud")!
        } else if self == .AppleMusic {
            return UIImage(named: "apple_music")!
        } else {
            fatalError()
        }
    }

    func asLowercaseString() -> String {
        if self == .Spotify {
            return "spotify"
        } else if self == .Soundcloud {
            return "soundcloud"
        } else if self == .AppleMusic {
            return "applemusic"
        } else {
            fatalError()
        }
    }
}