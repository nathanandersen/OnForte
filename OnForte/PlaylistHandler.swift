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

    private static var musicPlayer = IntegratedMusicPlayer()

    internal static func togglePlayingStatus(completionHandler: Bool -> Void) {
        musicPlayer.togglePlayingStatus(completionHandler)
    }

    internal static func playNextSong(completionHandler: (Bool) -> ()) {
        musicPlayer.playNextSong(completionHandler)
    }

    internal static var nowPlaying: Song?

    internal static var spotifySession: SPTSession?

    internal static func spotifySessionIsValid() -> Bool {
        return (spotifySession != nil && spotifySession!.isValid())
    }

    internal static var isHost: Bool = false
    internal static var playlistName: String = ""
    private static var votes = [String:VotingStatus]()

    /**
     Fetch the voting status for a song
    */
    internal static func getVotingStatus(id: String) -> VotingStatus {
        return votes[id]!
    }

    /**
     Downvote a song. This involves telling the server to update the score, then
     updating the local display of voting status.
    */
    internal static func downvote(id: String, completionHandler: (VotingStatus) -> Void) {
        Meteor.call("downvoteSong",params:[id]) { (result,error) in
            let newStatus = votes[id]!.downvote()
            votes.updateValue(newStatus, forKey: id)
            completionHandler(newStatus)
        }
    }

    /**
     Upvote a song. This involves telling the server to update the score, then
     updating the local display of voting status.
     */
    internal static func upvote(id: String, completionHandler: (VotingStatus) -> Void) {
        Meteor.call("upvoteSong",params:[id]) { (result,error) in
            let newStatus = votes[id]!.upvote()
            votes.updateValue(newStatus, forKey: id)
            completionHandler(newStatus)
        }
    }

    /**
     Insert a new voting status for an inserted song.
    */
    internal static func addVotingStatusForId(id: String) {
        votes.updateValue(VotingStatus.None, forKey: id)
    }

    /**
     Leave a playlist
    */
    internal static func leavePlaylist() {
        if self.isHost {
            self.musicPlayer.stop()
        }
        playlistId = ""
        playlistName = ""
        nowPlaying = nil
        isHost = false
        SongHandler.clearForNewPlaylist()
        centralNavigationController.leavePlaylist()
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