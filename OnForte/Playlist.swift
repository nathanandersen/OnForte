//
//  Playlist.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/30/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import StoreKit

let hostIsLoggedInToSpotifyKey = "hostIsLoggedInToSpotify"
let hostIsLoggedInToSoundcloudKey = "hostIsLoggedInToSoundcloud"
let hostIsLoggedInToAppleMusicKey = "hostIsLoggedInToAppleMusic"

class PlaylistToInsert {
    var name: String

    private static func generateRandomId() -> String {
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
            userIdKey: NSUserDefaults.standardUserDefaults().stringForKey(userIdKey)!,
            hostIsLoggedInToSpotifyKey: PlaylistHandler.spotifySessionIsValid(),
            hostIsLoggedInToSoundcloudKey: true,
            hostIsLoggedInToAppleMusicKey: PlaylistHandler.appleMusicLoginStatus
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
    var userId: String
    var hostIsLoggedInToSpotify: Bool
    var hostIsLoggedInToSoundcloud: Bool
    var hostIsLoggedInToAppleMusic: Bool
    var createDate: NSDate

    init(jsonData: AnyObject) {
        self._id = jsonData[mongoIdKey] as! String
        self.name = jsonData[nameKey] as! String
        self.playlistId = jsonData[playlistIdKey] as! String
        self.createDate = APIHandler.convertJSONDateToNSDate(jsonData[createDateKey] as! String)!
        self.userId = jsonData[userIdKey] as! String
        self.hostIsLoggedInToSpotify = jsonData[hostIsLoggedInToSpotifyKey] as! Bool
        self.hostIsLoggedInToSoundcloud = jsonData[hostIsLoggedInToSoundcloudKey] as! Bool
        self.hostIsLoggedInToAppleMusic = jsonData[hostIsLoggedInToAppleMusicKey] as! Bool
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