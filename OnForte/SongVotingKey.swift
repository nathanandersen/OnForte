//
//  SongVotingKey.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//
import Foundation

class SongVotingKey: Hashable {
    var id: String
    var title: String?
    var description: String?
    var service: Service
    var trackId: String

    var hashValue: Int {
        return self.id.hashValue
    }

    init(id: String, title: String?, description: String?, service: Service, trackId: String) {
        self.id = id
        self.title = title
        self.description = description
        self.service = service
        self.trackId = trackId
    }

    /*    init(doc: SongDocument) {
     self.id = doc._id
     self.title = doc.title
     self.description = doc.description
     self.service = Service(platform: doc.platform)
     self.trackId = doc.trackId
     }*/

    init(doc: MeteorSong) {
        self.id = doc._id
        self.title = doc.title
        self.description = doc.annotation
        self.service = Service(platform: doc.platform)
        self.trackId = doc.trackId
    }


}

func ==(lhs: SongVotingKey, rhs: SongVotingKey) -> Bool {
    return lhs.id == rhs.id
}