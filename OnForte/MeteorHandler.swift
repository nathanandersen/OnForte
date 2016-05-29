//
//  MeteorHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/28/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import SwiftDDP

/**
 This class handles all of the interactions with a Meteor server.
 */
class MeteorHandler: NSObject {
    // this will be a static object that handles all of the Meteor function calls, etc
    // pushing them onto a queue and stuff when not connected

    private let concurrentMeteorQueue = dispatch_queue_create("com.nathanandersen.OnForte.meteorQueue", DISPATCH_QUEUE_CONCURRENT)

    private static let operationQueue = NSOperationQueue()

    internal static var isConnected: Bool = false

    private static func addOperationToQueue(block: () -> Void) {
        print("Just added an operation.")
        operationQueue.suspended = !isConnected
        operationQueue.addOperationWithBlock(block)
    }


    internal static func connectToServer() {
        Meteor.connect("wss://onforte.herokuapp.com/websocket") {
            isConnected = true
            operationQueue.suspended = false
            print(operationQueue.operations)



            print("Connected to OnForte")
//            activityIndicator.showComplete("Connected")
            PlaylistHandler.playlistId = PlaylistHandler.playlistId
            // this handles the subscriptions
        }
    }

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

    internal static func createPlaylist(name: String, completionHandler: (Bool,String) -> ()) {
        let createdPlaylistId = generateRandomId()
        let playlistInfo = [name,createdPlaylistId]

        addOperationToQueue({
            Meteor.call("addPlaylist",params:playlistInfo,callback:{(result: AnyObject?,error:DDPError?) in
                if error != nil {
                    print(error)
                    completionHandler(false,"")
                } else {
                    completionHandler(true,createdPlaylistId)
                }
            })
            print("I executed")
        })
    }

    internal static func addSongToDatabase(song: Song, completionHandler: () -> Void) {
        Meteor.call("addSongWithAlbumArtURL",params: song.getSongDocFields(),callback: {(result: AnyObject?, error: DDPError?) in
            completionHandler()
        })
    }

    internal static func joinPlaylist(targetPlaylistId: String, completionHandler: (Bool,AnyObject?) -> ()) {
        Meteor.call("getInitialPlaylistInfo",params:[targetPlaylistId],callback: {(result: AnyObject?,error: DDPError?) in
            if error != nil {
                print(error)
                completionHandler(false,nil)
            } else {
                completionHandler(true,result)
            }
        })
    }

    internal static func registerSongAsPlayed(song: Song) {
        let paramObj = [PlaylistHandler.playlistId,
                        (song.title != nil) ? song.title! : "",
                        (song.description != nil) ? song.description! : "",
                        String(song.service!),
                        (song.trackId != nil) ? song.trackId! : "",
                        (song.artworkURL != nil) ? String(song.artworkURL!) : ""]
        Meteor.call("registerSongAsPlayed",params: paramObj,callback: nil)
    }

    internal static func removeSongFromQueue(songId: String) {
        Meteor.call("removeSongFromQueue",params: [songId],callback: nil)
    }

    internal static func setSongAsPlaying(song: Song) {
        Meteor.call("setSongAsPlaying",params: [PlaylistHandler.playlistId,song.getSongDocFields()],callback: nil)
    }

    internal static func subscribeToPublications(playlistId: String) {
        let paramObj = [playlistId]
        Meteor.subscribe("playedSongs",params: paramObj)
        Meteor.subscribe("queueSongs",params: paramObj)
    }

    internal static func unsubscribeFromPublications() {
        Meteor.unsubscribe("queueSongs")
        Meteor.unsubscribe("playedSongs")
    }

    internal static func upvoteSong(songId: String, completionHandler: (Bool) -> ()) {
        Meteor.call("upvoteSong",params:[songId]) { (result,error) in
            if error != nil {
                print(error)
                completionHandler(false)
                // handle error
            } else {
                completionHandler(true)
            }
        }
    }

    internal static func downvoteSong(songId: String, completionHandler: (Bool) -> ()) {
        Meteor.call("downvoteSong",params:[songId]) { (result,error) in
            if error != nil {
                print(error)
                completionHandler(false)
                // handle error
            } else {
                completionHandler(true)
            }
        }
    }
}