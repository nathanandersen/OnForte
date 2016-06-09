//
//  MusicPlatform.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/30/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation


enum MusicPlatform {
    case Spotify
    case Soundcloud
    case AppleMusic

    init(intValue: Int) {
        switch(intValue) {
        case 0: self = .Spotify
        case 1: self = .Soundcloud
        case 2: self = .AppleMusic
        case _: fatalError()
        }
    }

    init(str: String) {
        switch(str.lowercaseString) {
        case "applemusic": self = .AppleMusic
        case "spotify": self = .Spotify
        case "soundcloud": self = .Soundcloud
        case _: fatalError()
        }
    }

    func intValue() -> Int {
        if self == .Spotify {
            return 0
        } else if self == .Soundcloud {
            return 1
        } else if self == .AppleMusic {
            return 2
        } else {
            fatalError()
        }
    }

    func tintColor() -> UIColor {
        if self == .Spotify {
            return Style.spotifyGreen
        } else if self == .Soundcloud {
            return Style.soundcloudOrange
        } else if self == .AppleMusic {
            return Style.appleMusicRed
        } else {
            fatalError()
        }
    }

    func getImage() -> UIImage {
        if self == .Spotify {
            return UIImage(named: "spotify")!
        } else if self == .Soundcloud {
            return UIImage(named: "soundcloud")!
        } else if self == .AppleMusic {
            return UIImage(named: "apple_music")!
        } else {
            fatalError()
        }
    }

    func asLowercaseString() -> String {
        if self == .Spotify {
            return "spotify"
        } else if self == .Soundcloud {
            return "soundcloud"
        } else if self == .AppleMusic {
            return "applemusic"
        } else {
            fatalError()
        }
    }
}