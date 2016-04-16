//
//  Globals.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import MediaPlayer
import Contacts

// Current global variables.
var playlistId: String?
var spotifySession: SPTSession?
var nowPlaying: Song?
var keys: NSDictionary?
//var votes = [SongDocument:VotingStatus]()
var votes = [SongVotingKey:VotingStatus]()
var isHost: Bool = false
var playlistName: String!
var artworkHandler = ArtworkHandler()

var allLocalITunes: [Song] = []
var allLocalITunesOriginals: [MPMediaItem]? = []

var activityIndicator: ActivityIndicator!


class InviteContact {
    var isSelected: Bool = false
    let contact: CNContact

    init(contact: CNContact) {
        self.contact = contact
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("InviteContact does not support NSCoding")
    }

    func fullName() -> String? {
        return CNContactFormatter.stringFromContact(self.contact, style: .FullName)
    }
}

enum Service {
    case Spotify
    case Soundcloud
    case iTunes

    init(platform: String) {
        if platform.lowercaseString == "soundcloud" {
            self = .Soundcloud
        } else if platform.lowercaseString == "itunes" {
            self = .iTunes
        } else {
            self = .Spotify
        }
    }
    func asLowerCaseString() -> String {
        if self == .Spotify {
            return "spotify"
        } else if self == .Soundcloud {
            return "soundcloud"
        } else if self == .iTunes {
            return "itunes"
        } else {
            return "not a match"
        }
    }
}

enum VotingStatus {
    case Upvote
    case Downvote
    case None

    func upvote() -> VotingStatus {
        switch(self) {
        case .Downvote:
            return .None
        case _:
            return .Upvote
        }
    }

    func downvote() -> VotingStatus {
        switch(self) {
        case .Upvote:
            return .None
        case _:
            return .Downvote
        }
    }
}

extension NSLayoutConstraint {

    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}