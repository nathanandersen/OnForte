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
        if (query != ""){
            results = SongHandler.allLocalITunes.filter({ (song) -> Bool in
                let title: NSString = song.title!
                let range = title.rangeOfString(query, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            })
            completionHandler(success: true)
        } else {
            results = []
            completionHandler(success: false)
        }
    }
}