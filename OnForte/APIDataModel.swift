//
//  APIDataModel.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/29/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import CoreData



let nameKey = "name"
let titleKey = "title"
let annotationKey = "annotation"
let playlistIdKey = "playlistId"
let musicPlatformKey = "musicPlatform"
let artworkURLKey = "artworkURL"
let trackIdKey = "trackId"
let scoreKey = "score"
let mongoIdKey = "_id"
let createDateKey = "createDate"

class PlaylistToInsert {
    var name: String

    internal static func generateRandomId() -> String {
        let _base36chars_string = "0123456789abcdefghijklmnopqrstuvwxyz"
        let _base36chars = Array(_base36chars_string.characters)
        var uniqueId = "";
        for _ in 1...6 {
            let random = Int(arc4random_uniform(36))
            uniqueId = uniqueId + String(_base36chars[random])
        }
        return uniqueId;
    }

    init(name: String) {
        self.name = name
    }

    private func toDictionary() -> NSDictionary {
        return [
            nameKey: self.name,
            playlistIdKey: PlaylistToInsert.generateRandomId(),
            userIdKey: NSUserDefaults.standardUserDefaults().stringForKey(userIdKey)!
        ]
    }

    internal func toJSON() -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(self.toDictionary(), options: [])
    }
}

class Playlist: Hashable {
    var name: String
    var playlistId: String
    var _id: String
    var hostId: String
    //    var isLoggedInToSpotify: Bool
    //    var isLoggedInToSoundcloud: Bool
    //    var isLoggedInToAppleMusic: Bool
    var createDate: NSDate

    init(jsonData: AnyObject) {
        print(jsonData)
        self._id = jsonData[mongoIdKey] as! String
        self.name = jsonData[nameKey] as! String
        self.playlistId = jsonData[playlistIdKey] as! String
        self.createDate = APIHandler.convertJSONDateToNSDate(jsonData[createDateKey] as! String)!
        self.hostId = jsonData[userIdKey] as! String
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

class SearchSong: Hashable {
    var title: String?
    var annotation: String?
    var musicPlatform: MusicPlatform
    var artworkURL: NSURL?
    var trackId: String

    var hashValue: Int {
        get {
            return "\(self.title)+\(self.annotation)+\(self.artworkURL)+\(self.musicPlatform.asLowercaseString())+\(self.trackId))".hashValue
        }
    }

    init(title: String?, annotation: String?, musicPlatform: MusicPlatform, artworkURL: NSURL?, trackId: String) {
        self.title = title
        self.annotation = annotation
        self.musicPlatform = musicPlatform
        self.artworkURL = artworkURL
        self.trackId = trackId
    }

    private func toDictionary() -> NSDictionary {
        return [
            titleKey: (self.title != nil) ? self.title! : "",
            annotationKey: (self.annotation != nil) ? self.annotation! : "",
            playlistIdKey: PlaylistHandler.playlist!.playlistId,
            musicPlatformKey: self.musicPlatform.asLowercaseString(),
            artworkURLKey: (self.artworkURL != nil) ? self.artworkURL!.URLString : "",
            trackIdKey: self.trackId,
            scoreKey: 0,
            userIdKey: NSUserDefaults.standardUserDefaults().stringForKey(userIdKey)!
        ]
    }

    internal func toJSON() -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(self.toDictionary(), options: [])
    }
}

func ==(lhs: SearchSong, rhs: SearchSong) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class Song: Hashable {
    var title: String?
    var annotation: String?
    var _id: String
    var playlistId: String
    var createDate: NSDate
    var musicPlatform: MusicPlatform
    var artworkURL: NSURL?
    var trackId: String
    var score: Int
    var userId: String

    init(jsonData: AnyObject) {
        self._id = jsonData[mongoIdKey] as! String
        self.title = jsonData[titleKey] as? String
        self.annotation = jsonData[annotationKey] as? String
        self.playlistId = jsonData[playlistIdKey] as! String
        self.musicPlatform = MusicPlatform(str: jsonData[musicPlatformKey] as! String)
        self.createDate = APIHandler.convertJSONDateToNSDate(jsonData[createDateKey] as! String)!
        self.artworkURL = NSURL(string: jsonData[artworkURLKey] as! String) // how are we going to catch this optional?
        self.trackId = jsonData[trackIdKey] as! String
        self.score = jsonData[scoreKey] as! Int
        self.userId = jsonData[userIdKey] as! String
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