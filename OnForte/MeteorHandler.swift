//
//  MeteorHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/28/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import SwiftDDP

class MeteorHandler: NSObject {
    // this will be a static object that handles all of the Meteor function calls, etc
    // pushing them onto a stack and stuff when not connected

    // a stack

    internal static func connectToServer() {
        Meteor.connect("wss://onforte.herokuapp.com/websocket") {
            print("Connected to OnForte")
//            activityIndicator.showComplete("Connected")
            PlaylistHandler.playlistId = PlaylistHandler.playlistId
            // this handles the subscriptions
        }
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
//            let newStatus = votes[id]!.downvote()
//            votes.updateValue(newStatus, forKey: id)
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
            //            let newStatus = votes[id]!.downvote()
            //            votes.updateValue(newStatus, forKey: id)
        }
    }
}