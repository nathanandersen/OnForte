//
//  AppleMusicHandler.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

class LocalMusicHandler: SearchHandler {

    override func search(query: String, completionHandler: (success: Bool) -> Void) {
        let localResults = SongHandler.getLocalSongsByQuery(query)
        if localResults == nil {
            results = []
            completionHandler(success: false)
        } else {
            results = localResults!
            completionHandler(success: true)
        }
    }
}