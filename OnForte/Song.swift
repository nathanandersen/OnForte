//
//  Song.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/30/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation


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
let activeStatusKey = "activeStatus"


/**
 This enum encapsulates the 3 stages of the life cycle of a Song.
 */
enum ActiveStatus: Int {
    case Queue = 0
    case NowPlaying = 1
    case History = 2
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
            userIdKey: NSUserDefaults.standardUserDefaults().stringForKey(userIdKey)!,
            activeStatusKey: ActiveStatus.Queue.rawValue
        ]
    }

    internal func toJSON() -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(self.toDictionary(), options: [])
    }
}

func ==(lhs: SearchSong, rhs: SearchSong) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// This is used for JSON -> CoreData
class Song: SearchSong {
    var _id: String
    var playlistId: String
    var createDate: NSDate
    var score: Int
    var userId: String
    var activeStatus: ActiveStatus

    init(jsonData: AnyObject) {
        self._id = jsonData[mongoIdKey] as! String
        self.playlistId = jsonData[playlistIdKey] as! String
        self.createDate = APIHandler.convertJSONDateToNSDate(jsonData[createDateKey] as! String)!
        self.score = jsonData[scoreKey] as! Int
        self.userId = jsonData[userIdKey] as! String
        self.activeStatus = ActiveStatus(rawValue: jsonData[activeStatusKey] as! Int)!

        super.init(title: jsonData[titleKey] as? String,
                   annotation: jsonData[annotationKey] as? String,
                   musicPlatform: MusicPlatform(str: jsonData[musicPlatformKey] as! String),
                   artworkURL: NSURL(string: jsonData[artworkURLKey] as! String),
                   trackId: jsonData[trackIdKey] as! String)
    }


    override var hashValue: Int {
        get {
            return self._id.hashValue
        }
    }
}

func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
