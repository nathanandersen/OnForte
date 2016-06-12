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
    case LocalLibrary

    init(intValue: Int) {
        switch(intValue) {
        case 0: self = .Spotify
        case 1: self = .Soundcloud
        case 2: self = .LocalLibrary
        case 3: self = .AppleMusic
        case _: fatalError()
        }
    }

    init(str: String) {
        switch(str.lowercaseString) {
        case "applemusic": self = .AppleMusic
        case "spotify": self = .Spotify
        case "soundcloud": self = .Soundcloud
        case "local": self = .LocalLibrary
        case _: fatalError()
        }
    }

    func intValue() -> Int {
        switch(self) {
        case .Spotify:
            return 0
        case .Soundcloud:
            return 1
        case .LocalLibrary:
            return 2
        case .AppleMusic:
            return 3
        }
    }

    func tintColor() -> UIColor {
        switch(self) {
        case .Spotify:
            return Style.spotifyGreen
        case .Soundcloud:
            return Style.soundcloudOrange
        case .AppleMusic:
            return Style.appleMusicRed
        case .LocalLibrary:
            // what do i return?
            return UIColor.blackColor()
        }
    }

    func getImage() -> UIImage {
        switch(self) {
        case .Spotify:
            return UIImage(named: "spotify")!
        case .Soundcloud:
            return UIImage(named: "soundcloud")!
        case .AppleMusic:
            return UIImage(named: "apple_music")!
        case .LocalLibrary:
            return UIImage(named: "apple_music")!
        }
    }

    func asLowercaseString() -> String {
        switch(self) {
        case .Spotify:
            return "spotify"
        case .Soundcloud:
            return "soundcloud"
        case .AppleMusic:
            return "applemusic"
        case .LocalLibrary:
            return "locallibrary"
        }
    }
}