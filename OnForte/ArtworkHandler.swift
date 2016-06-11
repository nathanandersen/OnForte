//
//  ArtworkHandler.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
//import Alamofire

/**
 This is a cache for artwork music
 */
class ArtworkHandler {

    static var artworkCache: NSCache = NSCache()

    /**
     Look up the artwork, and once we have it (in cache or by async), send it to the
     completion handler.
    */
    static func lookupArtworkAsync(lookupURL: NSURL?, completionHandler: UIImage -> () ) {
        if let url = lookupURL {
            if let image = self.artworkCache.objectForKey(url) as? UIImage {
                // cache hit
                completionHandler(image)
            } else {
                // cache miss, so let's look up the image
                if let albumArtData = NSData(contentsOfURL: url) {
                    if let albumArt = UIImage(data: albumArtData){
                        self.artworkCache.setObject(albumArt, forKey: url)
                        completionHandler(albumArt)
                    }
                }
            }
        } else {
            // url was invalid
        }
    }
}