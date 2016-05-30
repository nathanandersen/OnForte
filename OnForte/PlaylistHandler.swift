//
//  PlaylistHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/11/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

class PlaylistHandler: NSObject {

    private static var _playlist: Playlist?

    internal static var playlist: Playlist? {
        get {
            return self._playlist
        }
        set {
            self._playlist = newValue
        }
    }

    internal static func isHost() -> Bool {
        if let p = playlist {
            return p.hostId == NSUserDefaults.standardUserDefaults().stringForKey(userIdKey)
        }
        return false
    }



/*    private static var _playlistId: String = ""
    internal static var playlistId: String {
        get {
            return self._playlistId
        }

        set {
            self._playlistId = newValue

            if newValue == "" {
                MeteorHandler.unsubscribeFromPublications()
            } else {
                MeteorHandler.subscribeToPublications(newValue)
            }
        }
    }*/

    private static var musicPlayer = IntegratedMusicPlayer()

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

    private static var _nowPlaying: InternalSong?

    internal static var nowPlaying: InternalSong? {
        get {
            return self._nowPlaying
        }
        set {
            self._nowPlaying = newValue
            NSNotificationCenter.defaultCenter().postNotificationName(updateSmallMusicPlayerKey, object: nil)
        }
    }

    internal static var spotifySession: SPTSession?

    internal static func spotifySessionIsValid() -> Bool {
        return (spotifySession != nil && spotifySession!.isValid())
    }

//    internal static var isHost: Bool = false
//    internal static var playlistName: String = ""

    private static var votes = Set<String>()

    internal static func hasBeenUpvoted(id: String) -> Bool {
        return votes.contains(id)
    }

    /**
     Downvote a song. This involves telling the server to update the score, then
     updating the local display of voting status.
    */
    internal static func downvote(id: String) {
        MeteorHandler.downvoteSong(id, completionHandler: {
            (result: Bool) in
            if result {
                votes.remove(id)
            }
        })
    }

    /**
     Upvote a song. This involves telling the server to update the score, then
     updating the local display of voting status.
     */
    internal static func upvote(id: String) {
        MeteorHandler.upvoteSong(id, completionHandler: {
            (result: Bool) in
            if result {
                votes.insert(id)
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
/*        if self.isHost {
            self.musicPlayer.stopCurrentSong()
        }*/
        self.playlist = nil
        //        playlistId = ""
//        playlistName = ""
        nowPlaying = nil
//        isHost = false
        SongHandler.clearForNewPlaylist()
    }

    /**
     Generate a random playlist Id
     */
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


/*        MeteorHandler.createPlaylist(name, completionHandler: {
            (result: Bool, playlistId: String) in
            if result {
                self.playlistId = playlistId
                print(playlistId)
                self.playlistName = name
                self.isHost = true
            }
            completionHandler(result)
        })*/
    }

    internal static func joinPlaylist(targetPlaylistId: String, completionHandler: (Bool,AnyObject?) -> ()) {
        print("implement join playlist non-meteor.")
        // this should be a call to APIHandler, an HTTP Get


        /*        MeteorHandler.joinPlaylist(targetPlaylistId, completionHandler: {
            (result: Bool, data: AnyObject?) in
            if data != nil {
                self.playlistId = targetPlaylistId
            }
            completionHandler(result,data)
        })*/
    }

}