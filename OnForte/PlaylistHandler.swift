//
//  PlaylistHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/11/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import StoreKit
import Foundation

let updateSearchSegmentedControlKey = "updateSearchSegmentedControl"

class PlaylistHandler: NSObject {

    internal static var playlist: Playlist?
    private static var musicPlayer = IntegratedMusicPlayer()
    internal static var nowPlaying: QueuedSong?
    internal static var spotifySession: SPTSession?
    private static var votes = Set<String>()

    internal static var appleMusicLoginStatus = false

    internal static func updateAppleMusicLoginStatus() {
        if #available(iOS 9.3, *) {
            let controller = SKCloudServiceController()
            controller.requestCapabilitiesWithCompletionHandler({
                response,error in
                if error != nil {
                    print(error)
                } else {
                    appleMusicLoginStatus = (response != SKCloudServiceCapability.None)
                }
                print(appleMusicLoginStatus)
            })
        } else {
            // Fallback on earlier versions
        }
    }


    internal static func isHost() -> Bool {
        if let p = playlist {
            return p.userId == NSUserDefaults.standardUserDefaults().stringForKey(userIdKey)
        }
        return false
    }

    internal static func updatePlaylistSettings() {
//        if let p = playlist {
        NSNotificationCenter.defaultCenter().postNotificationName(updateSearchSegmentedControlKey, object: nil)
//        }
    }


    internal static func togglePlayingStatus(completionHandler: Bool -> Void) {
        musicPlayer.togglePlayingStatus(completionHandler)
    }

    internal static func playNextSong(completionHandler: (Bool) -> ()) {
        musicPlayer.playNextSong({(result) in
            completionHandler(result)
        })
    }

    internal static func stop() {
        musicPlayer.stopCurrentSong()
    }

    internal static func fastForward(completionHandler: Bool -> Void) {
        musicPlayer.stopCurrentSong()

        musicPlayer.playNextSong({(result) in
            completionHandler(result)
        })
    }


    internal static func spotifySessionIsValid() -> Bool {
        return (spotifySession != nil && spotifySession!.isValid())
    }


    internal static func hasBeenUpvoted(id: String) -> Bool {
        return votes.contains(id)
    }

    /**
     Downvote a song. This involves telling the server to update the score, then
     updating the local display of voting status.
    */
    internal static func downvote(id: String) {
        APIHandler.downvoteSong(id, completion: {
            (result: Bool) in
            if result {
                votes.remove(id)
                APIHandler.updateAPIInformation()
            }
        })
    }

    /**
     Upvote a song. This involves telling the server to update the score, then
     updating the local display of voting status.
     */
    internal static func upvote(id: String) {
        APIHandler.upvoteSong(id, completion: {
            (result: Bool) in
            if result {
                votes.insert(id)
                APIHandler.updateAPIInformation()
            }
        })
    }

    /**
     Leave a playlist
    */
    internal static func leavePlaylist() {
        if isHost() {
            self.musicPlayer.stopCurrentSong()
        }
        self.playlist = nil
        nowPlaying = nil
        SongHandler.clearForNewPlaylist()
    }

    /**
     Try to create a playlist. CompletionHandler is called with the result
     of the creation.
    */
    internal static func createPlaylist(name: String, completionHandler: Bool -> ()) {
        APIHandler.createPlaylist(PlaylistToInsert(name: name), completion: {
            (result: Playlist?) in
            if let playlist = result {
                self.playlist = playlist
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }

    internal static func joinPlaylist(targetPlaylistId: String, completionHandler: (Bool) -> ()) {
        APIHandler.joinPlaylist(targetPlaylistId, completion: {
            (result: Playlist?) in
            if let playlist = result {
                self.playlist = playlist
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }

}