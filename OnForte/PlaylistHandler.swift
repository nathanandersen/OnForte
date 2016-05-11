//
//  PlaylistHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/11/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import SwiftDDP

class PlaylistHandler: NSObject {
    private static var _playlistId: String = ""
    internal static var playlistId: String {
        get {
            return self._playlistId
        }

        set {
            self._playlistId = newValue

            if newValue == "" {
                Meteor.unsubscribe("queueSongs")
                Meteor.unsubscribe("playedSongs")
                // unsubscribe
            } else {
                let paramObj = [newValue]
                Meteor.subscribe("playedSongs",params: paramObj)
                Meteor.subscribe("queueSongs",params: paramObj)
                // subscribe
            }
        }
    }

    internal static var isHost: Bool = false
    internal static var playlistName: String = ""

    internal static func leavePlaylist() {
        playlistId = ""
        playlistName = ""
        isHost = false
    }


    /**
     Generate a random playlist Id
     */
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

}