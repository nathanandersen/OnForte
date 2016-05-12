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

//var spotifySession: SPTSession?
//var nowPlaying: Song?
var keys: NSDictionary?
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
        } else if platform.lowercaseString == "spotify" {
            self = .Spotify
        } else {
            fatalError()
        }
    }

    init(intValue: Int) {
        switch(intValue) {
        case 0:
            self = .Spotify
        case 1:
            self = .Soundcloud
        case 2:
            self = .iTunes
        case _:
            fatalError()
        }
    }

    func intValue() -> Int {
        if self == .Spotify {
            return 0
        } else if self == .Soundcloud {
            return 1
        } else if self == .iTunes {
            return 2
        } else {
            fatalError()
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
            fatalError()
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
