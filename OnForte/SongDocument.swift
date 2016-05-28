//
//  SongDocument.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import SwiftDDP

class SongDocument: MeteorDocument, MeteorSong {
    //    var collection:String = "songs"
    var collection:String = "queueSongs"
    var _id: String = ""
    var playlistId: String = ""
    var title: String = ""
    var annotation: String?
    var artworkURL: String? = ""
    var platform: String = ""
    var score: Int = 0
    //    var played: Bool = false

    var trackId: String = ""

    // get all the property names
    func getPropertyNames() -> [String] {
        return Mirror(reflecting: self).children.filter { $0.label != nil }.map { $0.label! }
    }

    // get all the field values
    func getFields() -> NSDictionary {
        let fieldsDict = NSMutableDictionary()
        let properties = self.getPropertyNames()

        for name in properties {
            if let value = self.valueForKey(name) {
                fieldsDict.setValue(value, forKey: name)
            }
        }
        print("fields \(fieldsDict)")
        return fieldsDict as NSDictionary
    }

    required init(id: String, fields: NSDictionary?) {
        super.init(id: id, fields: fields)
        self._id = id
    }

    
}