//
//  Song.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//
import Foundation
import UIKit

class Song {
    var title: String?
    var description: String?
    var artworkURL: NSURL?
    var service: Service?
    var trackId: String?
    var id: String?

    init(title: String?, description: String?, service: Service?, trackId: String?, artworkURL: NSURL?) {
        self.title = title
        self.description = description
        self.service = service
        self.trackId = trackId
        self.artworkURL = artworkURL
    }

    init(songDoc: SongDocument) {
        self.title = songDoc.title
        self.trackId = String(songDoc.trackId)
        self.description = songDoc.annotation
        self.artworkURL = (songDoc.artworkURL != nil) ? NSURL(string: songDoc.artworkURL!) : nil
        self.service = Service(platform: songDoc.platform)
        self.id = songDoc._id
    }

    func getSongDocFields() -> [String] {
        let fields = [
            playlistId!,
            (self.title != nil) ? self.title! : "",
            (self.description != nil) ? self.description! : "",
            String(self.service!),
            (self.trackId != nil) ? self.trackId! : "",
            (self.artworkURL != nil) ? self.artworkURL!.URLString : ""
        ]
        return fields
    }

    func printToConsole() {
        print("Title: " + self.title!)
        print("Description: " + self.description!)
        print("Service: " + String(self.service))
        print("Track ID: " + self.trackId!)
        print("AlbumURL: " + String(self.artworkURL))
    }
}