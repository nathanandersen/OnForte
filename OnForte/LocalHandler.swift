//
//  iTunesSearchController.swift
//  Forte
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation
import Alamofire
import SwiftDDP
import SwiftyJSON

class LocalHandler: SearchHandler {

    override func search(query: String, completionHandler: (success: Bool) -> Void) {
        print(query)
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